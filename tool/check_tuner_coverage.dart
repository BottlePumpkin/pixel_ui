// tool/check_tuner_coverage.dart
//
// Scans PixelShapeStyle (and sibling value types) public fields,
// then cross-references tuner/lib/src/controls/*.dart file contents
// to detect drift: missing coverage, orphan controls, broken wiring.
//
// Usage:
//   dart run tool/check_tuner_coverage.dart [--json]
//
// Exit codes:
//   0 — no drift
//   1 — drift detected
//   2 — required path missing (lib/src/pixel_style.dart or tuner/lib/src/controls)
//
// Coverage model:
//
//   - A field is "covered" if any Dart file under tuner/lib/** references
//     either the field identifier as a whole word (e.g. `fillColor`) OR the
//     enclosing type name (e.g. `PixelCorners`, which credits tl/tr/bl/br
//     via the type-reference fallback). This captures composite controls
//     that abstract individual fields away (like `corner_picker.dart`
//     handling all four corners through presets) as well as fields exposed
//     only by the tuner state / home page instead of a dedicated control.
//
//   - A file in tuner/lib/src/controls/ is an "orphan" when it matches
//     neither a field identifier nor a target type anywhere in its source.
//     Other tuner files (home_page.dart, tuner_state.dart, code_panel.dart,
//     etc.) are scanned for coverage but are never reported as orphans —
//     they're non-control infrastructure.
//
//   - Same identifier across target types (e.g. `color` in both PixelShadow
//     and PixelTexture) is counted once.

import 'dart:convert';
import 'dart:io';

const List<String> targetTypes = <String>[
  'PixelCorners',
  'PixelShadow',
  'PixelTexture',
  'PixelShapeStyle',
];

/// Identifiers that live on widget APIs (e.g. `PixelBox.label`) rather than
/// on a [targetTypes] value object. Referencing one in a control counts as
/// coverage but these names are never required coverage — they don't surface
/// in the `missing` list.
const Set<String> widgetOnlyFields = <String>{'label'};

const String pixelStylePath = 'lib/src/pixel_style.dart';
const String tunerLibDir = 'tuner/lib';
const String controlsDir = 'tuner/lib/src/controls';

/// Scans [source] for `final <Type> <name>;` fields inside
/// `class <typeName> { ... }`. Tolerates `extends`/`with`/`implements` on the
/// class header. Excludes underscore-prefixed (private) fields.
List<String> scanPublicFields(String source, String typeName) {
  final classPattern = RegExp(
    r'class\s+' + RegExp.escape(typeName) + r'\b[^{]*\{([\s\S]*?)\n\}',
  );
  final match = classPattern.firstMatch(source);
  if (match == null) return <String>[];
  final body = match.group(1)!;
  final fieldPattern = RegExp(
    r'^\s*final\s+[\w<>?,\s]+\s+(\w+)\s*;',
    multiLine: true,
  );
  return fieldPattern
      .allMatches(body)
      .map((m) => m.group(1)!)
      .where((name) => !name.startsWith('_'))
      .toList();
}

/// Returns the subset of [candidates] appearing as whole-word identifiers
/// (`\b...\b`) in [source]. `_` is a word char, so `_tr` does not match `tr`.
Set<String> scanControlReferences(String source, Iterable<String> candidates) {
  final hits = <String>{};
  for (final name in candidates) {
    final pattern = RegExp(r'\b' + RegExp.escape(name) + r'\b');
    if (pattern.hasMatch(source)) hits.add(name);
  }
  return hits;
}

/// Given a [typeToFields] map (e.g. `'PixelCorners' → {'tl','tr','bl','br'}`)
/// and a [source] Dart file, returns the union of field names transitively
/// credited when the source references a whole-word target type.
Set<String> scanTypeReferences(
  String source,
  Map<String, Set<String>> typeToFields,
) {
  final hits = <String>{};
  for (final entry in typeToFields.entries) {
    final pattern = RegExp(r'\b' + RegExp.escape(entry.key) + r'\b');
    if (pattern.hasMatch(source)) hits.addAll(entry.value);
  }
  return hits;
}

class CoverageResult {
  final Set<String> missing;
  final Set<String> orphans;
  final Map<String, Set<String>> covered;

  CoverageResult({
    required this.missing,
    required this.orphans,
    required this.covered,
  });

  bool get hasDrift => missing.isNotEmpty || orphans.isNotEmpty;

  Map<String, dynamic> toJson() {
    final sortedCovered = <String, List<String>>{};
    for (final key in covered.keys.toList()..sort()) {
      sortedCovered[key] = covered[key]!.toList()..sort();
    }
    return <String, dynamic>{
      'missing': missing.toList()..sort(),
      'orphans': orphans.toList()..sort(),
      'covered': sortedCovered,
    };
  }
}

/// Compares the flat [fields] set (union across target types) with a map of
/// control file path → identifier references. Returns drift report: fields
/// never referenced (missing), controls referencing nothing in the set
/// (orphans), and per-control field hits (covered).
CoverageResult compare(
  Set<String> fields,
  Map<String, Set<String>> controlRefs,
) {
  final coveredFields = controlRefs.values.expand((s) => s).toSet();
  return compareWithCoverage(fields, controlRefs, coveredFields);
}

/// Like [compare] but takes an explicit [coveredFields] set so coverage can
/// come from a wider scan (e.g. all of `tuner/lib/**`) while orphan detection
/// stays scoped to [controlRefs] only.
///
/// [widgetFields] are identifiers from widget-level APIs (e.g. `PixelBox.label`)
/// that should count as a valid control reference but don't participate in the
/// `missing` calculation — they aren't style fields we insist be tunable.
CoverageResult compareWithCoverage(
  Set<String> fields,
  Map<String, Set<String>> controlRefs,
  Set<String> coveredFields, {
  Set<String> widgetFields = const <String>{},
}) {
  final perControl = <String, Set<String>>{};
  final orphans = <String>{};
  final orphanTargets = <String>{...fields, ...widgetFields};

  controlRefs.forEach((file, refs) {
    final hits = refs.intersection(orphanTargets);
    if (hits.isEmpty) {
      orphans.add(file);
    } else {
      perControl[file] = hits;
    }
  });

  final missing = fields.difference(coveredFields.intersection(fields));
  return CoverageResult(
    missing: missing,
    orphans: orphans,
    covered: perControl,
  );
}

Future<void> main(List<String> args) async {
  final jsonMode = args.contains('--json');

  final pixelStyleFile = File(pixelStylePath);
  if (!await pixelStyleFile.exists()) {
    stderr.writeln('ERROR: $pixelStylePath not found. Run from project root.');
    exit(2);
  }
  final pixelStyleSrc = await pixelStyleFile.readAsString();

  final typeToFields = <String, Set<String>>{};
  final allFields = <String>{};
  for (final type in targetTypes) {
    final fields = scanPublicFields(pixelStyleSrc, type).toSet();
    typeToFields[type] = fields;
    allFields.addAll(fields);
  }

  final tunerDirEntry = Directory(tunerLibDir);
  if (!await tunerDirEntry.exists()) {
    stderr.writeln('ERROR: $tunerLibDir not found.');
    exit(2);
  }

  // Two-tier scan: controls are eligible for "orphan" status; non-control
  // files in tuner/lib contribute to coverage but not to orphan detection.
  final controlRefs = <String, Set<String>>{};
  final coveredFields = <String>{};
  final scanTargets = <String>{...allFields, ...widgetOnlyFields};
  await for (final entity in tunerDirEntry.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final src = await entity.readAsString();
    final hits = scanControlReferences(src, scanTargets)
      ..addAll(scanTypeReferences(src, typeToFields));
    coveredFields.addAll(hits);
    if (entity.path.startsWith('$controlsDir/')) {
      final relPath = entity.path.replaceFirst('$controlsDir/', '');
      controlRefs[relPath] = hits;
    }
  }

  final result = compareWithCoverage(
    allFields,
    controlRefs,
    coveredFields,
    widgetFields: widgetOnlyFields,
  );

  if (jsonMode) {
    stdout.writeln(jsonEncode(result.toJson()));
  } else {
    stdout.writeln('✅ Covered (${result.covered.length} files):');
    for (final entry in result.covered.entries) {
      stdout.writeln('  - ${entry.key} → ${entry.value.join(", ")}');
    }
    stdout.writeln('');
    stdout.writeln('❌ Missing fields (${result.missing.length}):');
    for (final m in result.missing) {
      stdout.writeln('  - $m');
    }
    stdout.writeln('');
    stdout.writeln('⚠️  Orphan controls (${result.orphans.length}):');
    for (final o in result.orphans) {
      stdout.writeln('  - $o');
    }
  }

  exit(result.hasDrift ? 1 : 0);
}
