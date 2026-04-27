// tool/check_readme_version.dart
//
// Guards against the recurring "README install pin lags pubspec version"
// drift (cycle #1 #19, cycle #3 #50). Runs in CI on every PR/push and
// fails the build when the README pin's major.minor falls behind the
// pubspec version's major.minor.
//
// Usage:
//   dart run tool/check_readme_version.dart           # check, exit 1 if drift
//   dart run tool/check_readme_version.dart --json    # machine-readable
//   dart run tool/check_readme_version.dart --fix     # auto-update README
//
// Exit codes:
//   0 — no drift (or drift was fixed in --fix mode)
//   1 — drift detected (and --fix not passed)
//   2 — required path missing or unparseable
//
// Drift rule:
//   README pin's `^X.Y.Z?` constraint must satisfy pubspec's current
//   `version: A.B.C`. Concretely: README's (major, minor) must equal
//   pubspec's (major, minor). A pin like `^0.5.0` covers all of 0.5.x
//   (caret semantics), so we don't require the patch to match.
//
//   Pre-1.0 caveat: under semver-pre-1.0, `^0.5.0` does NOT cover 0.6.0.
//   So a pubspec at 0.6.0 with README pinned at `^0.5.0` IS drift.

import 'dart:convert';
import 'dart:io';

const String pubspecPath = 'pubspec.yaml';
const String readmePath = 'README.md';

// Matches `pixel_ui: ^X.Y` or `pixel_ui: ^X.Y.Z` inside a fenced code block.
// We anchor on the package name to avoid matching unrelated lines.
final RegExp _readmePinRe = RegExp(
  r'pixel_ui:\s*\^(\d+)\.(\d+)(?:\.(\d+))?',
);

final RegExp _pubspecVersionRe = RegExp(
  r'^version:\s*(\d+)\.(\d+)\.(\d+)',
  multiLine: true,
);

class _SemVer {
  _SemVer(this.major, this.minor, [this.patch]);
  final int major;
  final int minor;
  final int? patch;

  String get caret => '^$major.$minor.${patch ?? 0}';
  @override
  String toString() => '$major.$minor${patch != null ? ".$patch" : ""}';
}

/// Returns null when the file is missing or no version line parses.
_SemVer? _parsePubspecVersion(String pubspecSrc) {
  final m = _pubspecVersionRe.firstMatch(pubspecSrc);
  if (m == null) return null;
  return _SemVer(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

/// Returns the *first* `pixel_ui: ^X.Y[.Z]` pin found in README.
_SemVer? _parseReadmePin(String readmeSrc) {
  final m = _readmePinRe.firstMatch(readmeSrc);
  if (m == null) return null;
  return _SemVer(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    m.group(3) == null ? null : int.parse(m.group(3)!),
  );
}

bool _readmeCoversPubspec(_SemVer readme, _SemVer pubspec) {
  // Pre-1.0 (major == 0): caret pins lock the minor. README's (major, minor)
  // must equal pubspec's (major, minor).
  if (readme.major == 0 && pubspec.major == 0) {
    return readme.minor == pubspec.minor;
  }
  // 1.0+: caret pins lock the major. README's major must equal pubspec's
  // major, and README's minor must be ≤ pubspec's minor (covers all 1.x ≥ pin).
  return readme.major == pubspec.major && readme.minor <= pubspec.minor;
}

void main(List<String> args) {
  final json = args.contains('--json');
  final fix = args.contains('--fix');

  final pubspecFile = File(pubspecPath);
  final readmeFile = File(readmePath);

  if (!pubspecFile.existsSync()) {
    _emit(json, _Result.error('missing_pubspec', '$pubspecPath not found'));
    exit(2);
  }
  if (!readmeFile.existsSync()) {
    _emit(json, _Result.error('missing_readme', '$readmePath not found'));
    exit(2);
  }

  final pubspecSrc = pubspecFile.readAsStringSync();
  final readmeSrc = readmeFile.readAsStringSync();

  final pubspec = _parsePubspecVersion(pubspecSrc);
  if (pubspec == null) {
    _emit(json,
        _Result.error('unparseable_pubspec', 'no `version:` line in pubspec'));
    exit(2);
  }

  final readme = _parseReadmePin(readmeSrc);
  if (readme == null) {
    _emit(
      json,
      _Result.error(
        'missing_readme_pin',
        'no `pixel_ui: ^X.Y[.Z]` pin found in $readmePath. '
            'Add an Install snippet so this check can guard it.',
      ),
    );
    exit(2);
  }

  if (_readmeCoversPubspec(readme, pubspec)) {
    _emit(
      json,
      _Result.ok(
        readme: readme,
        pubspec: pubspec,
        message: 'README pin ${readme.caret} covers pubspec $pubspec.',
      ),
    );
    exit(0);
  }

  // Drift.
  if (fix) {
    final newPin = _SemVer(pubspec.major, pubspec.minor, 0);
    final patched = readmeSrc.replaceFirst(
      _readmePinRe,
      'pixel_ui: ${newPin.caret}',
    );
    readmeFile.writeAsStringSync(patched);
    _emit(
      json,
      _Result.fixed(
        from: readme,
        to: newPin,
        pubspec: pubspec,
      ),
    );
    exit(0);
  }

  _emit(
    json,
    _Result.drift(
      readme: readme,
      pubspec: pubspec,
    ),
  );
  exit(1);
}

class _Result {
  _Result._({
    required this.kind,
    this.code,
    this.message,
    this.readme,
    this.pubspec,
    this.fromPin,
    this.toPin,
  });

  factory _Result.ok({
    required _SemVer readme,
    required _SemVer pubspec,
    required String message,
  }) =>
      _Result._(
        kind: 'ok',
        readme: readme,
        pubspec: pubspec,
        message: message,
      );

  factory _Result.drift({
    required _SemVer readme,
    required _SemVer pubspec,
  }) =>
      _Result._(
        kind: 'drift',
        readme: readme,
        pubspec: pubspec,
      );

  factory _Result.fixed({
    required _SemVer from,
    required _SemVer to,
    required _SemVer pubspec,
  }) =>
      _Result._(
        kind: 'fixed',
        readme: to,
        pubspec: pubspec,
        fromPin: from,
        toPin: to,
      );

  factory _Result.error(String code, String message) =>
      _Result._(kind: 'error', code: code, message: message);

  final String kind;
  final String? code;
  final String? message;
  final _SemVer? readme;
  final _SemVer? pubspec;
  final _SemVer? fromPin;
  final _SemVer? toPin;

  Map<String, dynamic> toJson() => {
        'kind': kind,
        if (code != null) 'code': code,
        if (message != null) 'message': message,
        if (readme != null) 'readme_pin': readme!.caret,
        if (pubspec != null) 'pubspec_version': pubspec.toString(),
        if (fromPin != null) 'fixed_from': fromPin!.caret,
        if (toPin != null) 'fixed_to': toPin!.caret,
      };
}

void _emit(bool json, _Result r) {
  if (json) {
    stdout.writeln(jsonEncode(r.toJson()));
    return;
  }
  switch (r.kind) {
    case 'ok':
      stdout.writeln('✅ ${r.message}');
      break;
    case 'drift':
      stderr.writeln('❌ README install pin is stale.');
      stderr.writeln('   pubspec.yaml version : ${r.pubspec}');
      stderr.writeln('   README.md  pin       : ${r.readme!.caret}');
      stderr.writeln('');
      stderr.writeln(
        '   Bump README to `pixel_ui: ^${r.pubspec!.major}.${r.pubspec!.minor}.0` '
        'or run:',
      );
      stderr.writeln('     dart run tool/check_readme_version.dart --fix');
      break;
    case 'fixed':
      stdout.writeln(
        '🔧 README pin updated: ${r.fromPin!.caret} → ${r.toPin!.caret} '
        '(pubspec at ${r.pubspec}).',
      );
      break;
    case 'error':
      stderr.writeln('⚠️  ${r.message}');
      break;
  }
}
