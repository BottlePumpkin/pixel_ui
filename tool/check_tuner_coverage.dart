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
// Coverage is identifier-based: a control "covers" a field when the field's
// identifier appears as a whole word anywhere in the control's Dart source.
// Same identifier across target types (e.g. `color` in both PixelShadow and
// PixelTexture) is counted once — any mention credits coverage for the shared
// name across classes.

import 'dart:convert';
import 'dart:io';

const List<String> targetTypes = <String>[
  'PixelCorners',
  'PixelShadow',
  'PixelTexture',
  'PixelShapeStyle',
];

const String pixelStylePath = 'lib/src/pixel_style.dart';
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
  final covered = <String>{};
  final perControl = <String, Set<String>>{};
  final orphans = <String>{};

  controlRefs.forEach((file, refs) {
    final hits = refs.intersection(fields);
    if (hits.isEmpty) {
      orphans.add(file);
    } else {
      perControl[file] = hits;
      covered.addAll(hits);
    }
  });

  final missing = fields.difference(covered);
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

  final allFields = <String>{};
  for (final type in targetTypes) {
    allFields.addAll(scanPublicFields(pixelStyleSrc, type));
  }

  final controlsDirEntry = Directory(controlsDir);
  if (!await controlsDirEntry.exists()) {
    stderr.writeln('ERROR: $controlsDir not found.');
    exit(2);
  }
  final controlRefs = <String, Set<String>>{};
  await for (final entity in controlsDirEntry.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final src = await entity.readAsString();
      final refs = scanControlReferences(src, allFields);
      final relPath = entity.path.replaceFirst('$controlsDir/', '');
      controlRefs[relPath] = refs;
    }
  }

  final result = compare(allFields, controlRefs);

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
