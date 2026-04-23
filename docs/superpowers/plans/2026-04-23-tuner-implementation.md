# Tuner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a public web-based PixelShapeStyle tuner at `https://bottlepumpkin.github.io/pixel_ui/` — users adjust a live-rendered `PixelShapeStyle` via Material controls wrapped in pixel chrome, copy the generated Dart code, and share the URL.

**Architecture:** A sibling Flutter web app at `tuner/` (publish_to: none) depends on pixel_ui via path `../`, uses a single `ValueNotifier<PixelShapeStyle>` for state, separates pure functions (`code_generator`, `color_hex_parser`) for unit testing, and deploys to GitHub Pages via `.github/workflows/deploy-tuner.yml` on main pushes affecting `tuner/**`, `lib/**`, `pubspec.yaml`, or `assets/**`.

**Tech Stack:** Flutter 3.32.7 web (ubuntu-latest runner), Material 2 forms (pixel palette), pixel_ui (path dep), `PixelText.mulmaruMono` for code panel, GitHub Pages via `actions/deploy-pages@v4`.

**Specs:**
- `docs/superpowers/specs/2026-04-23-tuner-design.md` (visual refinements R1/R2/R3, scope confirmations)
- `docs/specs/2026-04-22-tuner-design.md` (base spec: structure, state model, code-gen rules, control-by-control UX, deploy workflow)

**Branch:** `feat/tuner` (already active)

---

## File Structure

**Create (all under `tuner/` unless noted):**

| Path | Responsibility |
|---|---|
| `tuner/pubspec.yaml` | Tuner package manifest; `publish_to: none`; `pixel_ui: path ../` |
| `tuner/analysis_options.yaml` | Flutter lints |
| `tuner/lib/main.dart` | App entry: `runApp(MaterialApp(theme: pixelTunerTheme, home: HomePage()))` |
| `tuner/lib/src/tuner_state.dart` | `ValueNotifier<PixelShapeStyle>` + `setXxx` methods |
| `tuner/lib/src/theme.dart` | Material ThemeData with pixel palette + Mulmaru textTheme |
| `tuner/lib/src/home_page.dart` | Responsive 30/70 layout, wires state to panels |
| `tuner/lib/src/preview_panel.dart` | Checker bg + 6x PixelBox rendering current style |
| `tuner/lib/src/code_panel.dart` | Dark bg, `PixelText.mulmaruMono`, SelectableText, Copy button |
| `tuner/lib/src/code_generator.dart` | Pure `String generateCode(PixelShapeStyle)` |
| `tuner/lib/src/color_hex_parser.dart` | Pure `Color? parseHex(String)` |
| `tuner/lib/src/widgets/pixel_card.dart` | Layered 2px outer + 1px inset highlight border (R3) |
| `tuner/lib/src/widgets/pixel_section_header.dart` | Small left-bar + title text |
| `tuner/lib/src/controls/corner_picker.dart` | SegmentedButton (sharp/xs/sm/md/lg/xl/custom) + custom depth slider |
| `tuner/lib/src/controls/color_hex_input.dart` | Swatch + hex TextField + optional `enabled` checkbox for nullable colors |
| `tuner/lib/src/controls/border_width_slider.dart` | 0~4 int Slider (disabled when borderColor is null) |
| `tuner/lib/src/controls/shadow_editor.dart` | Enabled + presets (sm/md/lg) + dx/dy sliders + color |
| `tuner/lib/src/controls/texture_editor.dart` | Enabled + density/size/seed/color + 🎲 seed randomizer |
| `tuner/test/code_generator_test.dart` | Pure function unit tests |
| `tuner/test/color_hex_parser_test.dart` | Pure function unit tests |
| `tuner/web/index.html` | Custom title/meta/theme-color |
| `.github/workflows/deploy-tuner.yml` | GitHub Pages deploy workflow |

**Modify:**
- `README.md` — add Live Tuner badge + hero link

**No modification to `lib/`, `example/`, `pubspec.yaml` (root), or any other published-package artifact.** The tuner is a purely additive sibling.

---

## Task 1: Scaffold tuner/ directory

**Files:**
- Create: `tuner/` (via `flutter create --platforms=web`)
- Modify: `tuner/pubspec.yaml`, `tuner/analysis_options.yaml`

- [ ] **Step 1: Create the Flutter web project**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter create --platforms=web --project-name=pixel_ui_tuner --org=com.bottlepumpkin tuner
```

Expected: `tuner/` directory created with `lib/main.dart`, `web/`, `pubspec.yaml`, etc.

- [ ] **Step 2: Replace tuner/pubspec.yaml**

Overwrite `tuner/pubspec.yaml` with:

```yaml
name: pixel_ui_tuner
description: "Interactive tuner for the pixel_ui PixelShapeStyle."
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.8.0
  flutter: '>=3.32.0'

dependencies:
  flutter:
    sdk: flutter
  pixel_ui:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Replace tuner/analysis_options.yaml**

Overwrite with:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
```

- [ ] **Step 4: Delete Flutter template test file and placeholder lib files**

Run:
```bash
rm -rf tuner/test/widget_test.dart
rm tuner/lib/main.dart
```

We'll rewrite `main.dart` in Task 2.

- [ ] **Step 5: pub get**

Run:
```bash
cd tuner
fvm flutter pub get
cd ..
```

Expected: `Got dependencies!` with `pixel_ui` resolved from path.

- [ ] **Step 6: Commit**

```bash
git add tuner/
git commit -m "feat(tuner): scaffold Flutter web project with pixel_ui path dep"
```

---

## Task 2: TunerState

**Files:**
- Create: `tuner/lib/src/tuner_state.dart`
- Create: `tuner/test/tuner_state_test.dart`

- [ ] **Step 1: Write the state class**

Create `tuner/lib/src/tuner_state.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Single source of truth for the tuner's current [PixelShapeStyle].
class TunerState extends ValueNotifier<PixelShapeStyle> {
  TunerState() : super(_initial);

  static const _initial = PixelShapeStyle(
    corners: PixelCorners.lg,
    fillColor: Color(0xFF5A8A3A),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
    shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
  );

  void setCorners(PixelCorners corners) =>
      value = value.copyWith(corners: corners);

  void setFillColor(Color color) =>
      value = value.copyWith(fillColor: color);

  void setBorderColor(Color? color) =>
      value = value.copyWith(borderColor: color);

  void setBorderWidth(int width) =>
      value = value.copyWith(borderWidth: width);

  void setShadow(PixelShadow? shadow) =>
      value = value.copyWith(shadow: shadow);

  void setTexture(PixelTexture? texture) =>
      value = value.copyWith(texture: texture);
}
```

- [ ] **Step 2: Write unit tests**

Create `tuner/test/tuner_state_test.dart`:

```dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/tuner_state.dart';

void main() {
  group('TunerState', () {
    test('initial state uses lg corners, green fill, thin border, sm shadow', () {
      final state = TunerState();
      expect(state.value.corners, PixelCorners.lg);
      expect(state.value.fillColor, const Color(0xFF5A8A3A));
      expect(state.value.borderColor, const Color(0xFF2A4820));
      expect(state.value.borderWidth, 1);
      expect(state.value.shadow?.offset, const Offset(1, 1));
      expect(state.value.texture, isNull);
    });

    test('setCorners updates corners and notifies listeners', () {
      final state = TunerState();
      var notified = 0;
      state.addListener(() => notified++);
      state.setCorners(PixelCorners.sharp);
      expect(state.value.corners, PixelCorners.sharp);
      expect(notified, 1);
    });

    test('setBorderColor(null) clears border color', () {
      final state = TunerState();
      state.setBorderColor(null);
      expect(state.value.borderColor, isNull);
    });

    test('setShadow(null) clears shadow', () {
      final state = TunerState();
      state.setShadow(null);
      expect(state.value.shadow, isNull);
    });
  });
}
```

- [ ] **Step 3: Run tests**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter test
```

Expected: `+4: All tests passed!`

- [ ] **Step 4: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/tuner_state.dart tuner/test/tuner_state_test.dart
git commit -m "feat(tuner): add TunerState ValueNotifier with copyWith setters"
```

---

## Task 3: Theme

**Files:**
- Create: `tuner/lib/src/theme.dart`

- [ ] **Step 1: Write theme.dart**

Create `tuner/lib/src/theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

final pixelTunerTheme = ThemeData(
  useMaterial3: false,
  scaffoldBackgroundColor: const Color(0xFFF5F1E8),
  primaryColor: const Color(0xFF5A8A3A),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF5A8A3A),
    secondary: Color(0xFFE07A3C),
    surface: Color(0xFFE8DFC6),
    error: Color(0xFFC94A4A),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2A2A2A),
    onSurface: Color(0xFF2A2A2A),
    onError: Color(0xFFFFFFFF),
  ),
  textTheme: Typography.blackMountainView.apply(
    fontFamily: PixelText.mulmaruFontFamily,
    package: PixelText.mulmaruPackage,
  ),
  sliderTheme: const SliderThemeData(
    trackHeight: 4,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
    isDense: true,
  ),
  visualDensity: VisualDensity.compact,
);
```

- [ ] **Step 2: Commit**

```bash
git add tuner/lib/src/theme.dart
git commit -m "feat(tuner): add theme.dart with Material 2 + pixel palette"
```

---

## Task 4: PixelCard widget (R3 layered border)

**Files:**
- Create: `tuner/lib/src/widgets/pixel_card.dart`

- [ ] **Step 1: Write PixelCard with layered 2px outer + 1px inset highlight**

Create `tuner/lib/src/widgets/pixel_card.dart`:

```dart
import 'package:flutter/widgets.dart';

/// Retro-raised container: 2px outer solid border + 1px inset top/left
/// highlight. Imitates NES.css raised-button feel without shadows.
class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PixelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A2A), width: 2),
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(
            top: BorderSide(color: Color(0x30FFFFFF), width: 1),
            left: BorderSide(color: Color(0x30FFFFFF), width: 1),
          ),
        ),
        child: child,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add tuner/lib/src/widgets/pixel_card.dart
git commit -m "feat(tuner): add PixelCard with layered pixel-retro border (R3)"
```

---

## Task 5: PixelSectionHeader widget

**Files:**
- Create: `tuner/lib/src/widgets/pixel_section_header.dart`

- [ ] **Step 1: Write PixelSectionHeader**

Create `tuner/lib/src/widgets/pixel_section_header.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Section title with a 4px vertical accent bar on the left.
class PixelSectionHeader extends StatelessWidget {
  final String title;
  const PixelSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          const SizedBox(
            width: 4,
            height: 20,
            child: ColoredBox(color: Color(0xFF5A8A3A)),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: PixelText.mulmaru(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add tuner/lib/src/widgets/pixel_section_header.dart
git commit -m "feat(tuner): add PixelSectionHeader with pixel-green accent bar"
```

---

## Task 6: preview_panel (6x scale + checker background)

**Files:**
- Create: `tuner/lib/src/preview_panel.dart`

- [ ] **Step 1: Write preview_panel**

Create `tuner/lib/src/preview_panel.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'tuner_state.dart';
import 'widgets/pixel_card.dart';
import 'widgets/pixel_section_header.dart';

/// Dominant preview area: checker-textured backdrop with the current style
/// rendered as a PixelBox at 6x logical-to-render scale.
class PreviewPanel extends StatelessWidget {
  final TunerState state;
  const PreviewPanel({super.key, required this.state});

  static const _logicalWidth = 80;
  static const _logicalHeight = 24;
  static const _scale = 6;

  @override
  Widget build(BuildContext context) {
    return PixelCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PixelSectionHeader('PREVIEW'),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 2,
            child: CustomPaint(
              painter: _CheckerPainter(),
              child: Center(
                child: ValueListenableBuilder<PixelShapeStyle>(
                  valueListenable: state,
                  builder: (context, style, _) {
                    return PixelBox(
                      logicalWidth: _logicalWidth,
                      logicalHeight: _logicalHeight,
                      pixelSize: _scale.toDouble(),
                      style: style,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  static const _tile = 8.0;
  static const _dark = Color(0xFFE0D9C4);
  static const _light = Color(0xFFEDE6D0);

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = _dark;
    final paintLight = Paint()..color = _light;
    canvas.drawRect(Offset.zero & size, paintLight);
    for (double y = 0; y < size.height; y += _tile) {
      for (double x = 0; x < size.width; x += _tile) {
        final isDark = ((x / _tile).floor() + (y / _tile).floor()) % 2 == 0;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, _tile, _tile), paintDark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter oldDelegate) => false;
}
```

NOTE: verify the `PixelBox` public API in `lib/src/pixel_box.dart`. If `pixelSize:` parameter doesn't exist, consult the API and replace with the correct way to render at 6x (e.g., a wrapping `Transform.scale` or an intrinsic logical-to-physical helper). Commit only after the build succeeds.

- [ ] **Step 2: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: `No issues found!`

If analyze complains about `pixelSize` being an unknown parameter, read `lib/src/pixel_box.dart` in the pixel_ui package and substitute the correct API (likely `SizedBox(width: _logicalWidth * _scale, height: _logicalHeight * _scale, child: PixelBox(...))` with intrinsic logical sizing). Fix and re-analyze.

- [ ] **Step 3: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/preview_panel.dart
git commit -m "feat(tuner): add preview_panel with 6x PixelBox + checker bg"
```

---

## Task 7: home_page with 30/70 layout + wire state

**Files:**
- Create: `tuner/lib/src/home_page.dart`
- Create: `tuner/lib/main.dart`

This task produces a runnable app (no controls yet — that's Task 9+). Controls panel shows a single placeholder card.

- [ ] **Step 1: Write home_page with 30/70 layout**

Create `tuner/lib/src/home_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'preview_panel.dart';
import 'tuner_state.dart';
import 'widgets/pixel_card.dart';
import 'widgets/pixel_section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _state = TunerState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          return SafeArea(
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: isWide
                      ? _WideLayout(state: _state)
                      : _StackedLayout(state: _state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF5A8A3A),
      child: Text(
        'PIXEL UI TUNER',
        style: PixelText.mulmaru(
          fontSize: 24,
          color: const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final TunerState state;
  const _WideLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 30,
          child: _ControlsPanel(state: state),
        ),
        Expanded(
          flex: 70,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PreviewPanel(state: state),
          ),
        ),
      ],
    );
  }
}

class _StackedLayout extends StatelessWidget {
  final TunerState state;
  const _StackedLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PreviewPanel(state: state),
          const SizedBox(height: 16),
          _ControlsPanel(state: state),
        ],
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  final TunerState state;
  const _ControlsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PixelSectionHeader('CONTROLS'),
                SizedBox(height: 8),
                Text('(controls coming in later tasks)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Write main.dart**

Create `tuner/lib/main.dart`:

```dart
import 'package:flutter/material.dart';

import 'src/home_page.dart';
import 'src/theme.dart';

void main() {
  runApp(const TunerApp());
}

class TunerApp extends StatelessWidget {
  const TunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pixel_ui Tuner',
      theme: pixelTunerTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 3: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Build (not run — sanity that the web target compiles)**

Run:
```bash
fvm flutter build web --release --base-href /pixel_ui/
```

Expected: Build succeeds. Output in `tuner/build/web/`. If compilation fails due to pixel_ui API mismatch, consult the package source and fix.

- [ ] **Step 5: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/main.dart tuner/lib/src/home_page.dart
git commit -m "feat(tuner): scaffold home_page with 30/70 layout + preview panel wired"
```

---

## Task 8: Smoke-test M1 in chrome

**Files:** None modified — manual verification step.

- [ ] **Step 1: Run in chrome**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter run -d chrome
```

Expected: browser opens. Verify:
- Green header bar at top with "PIXEL UI TUNER" in Mulmaru font
- Left ~30%: a `PixelCard` containing "CONTROLS" section header + placeholder text
- Right ~70%: a `PixelCard` containing "PREVIEW" section header + checker-textured area with a green/brown `PixelBox` rendered at 6x
- Resize browser to < 720px: layout becomes stacked (preview on top, controls below)
- DevTools Console: no errors

If anything looks wrong (e.g., Mulmaru doesn't render, PixelBox missing, layout broken), fix in the corresponding Task 2-7 file and re-run.

- [ ] **Step 2: Record findings**

No commit needed for a pure smoke test. Proceed to Task 9 only if the smoke test passes. If you discovered bugs requiring code fixes, commit the fixes separately with messages like `fix(tuner): …` and proceed.

---

## Task 9: color_hex_parser (TDD)

**Files:**
- Create: `tuner/test/color_hex_parser_test.dart`
- Create: `tuner/lib/src/color_hex_parser.dart`

- [ ] **Step 1: Write the failing tests**

Create `tuner/test/color_hex_parser_test.dart`:

```dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui_tuner/src/color_hex_parser.dart';

void main() {
  group('parseHex', () {
    test('parses 6-hex with leading hash as opaque RGB', () {
      expect(parseHex('#AABBCC'), const Color(0xFFAABBCC));
    });

    test('parses 6-hex without leading hash', () {
      expect(parseHex('aabbcc'), const Color(0xFFAABBCC));
    });

    test('parses 8-hex as ARGB', () {
      expect(parseHex('FF112233'), const Color(0xFF112233));
      expect(parseHex('80112233'), const Color(0x80112233));
    });

    test('accepts uppercase and lowercase', () {
      expect(parseHex('aBcDeF'), const Color(0xFFABCDEF));
    });

    test('returns null for too-short input', () {
      expect(parseHex('12'), isNull);
      expect(parseHex(''), isNull);
    });

    test('returns null for non-hex characters', () {
      expect(parseHex('XYZ123'), isNull);
      expect(parseHex('#GGHHII'), isNull);
    });

    test('returns null for 7-char (between 6 and 8)', () {
      expect(parseHex('1234567'), isNull);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter test test/color_hex_parser_test.dart
```

Expected: compile failure (`parseHex` not defined).

- [ ] **Step 3: Write the implementation**

Create `tuner/lib/src/color_hex_parser.dart`:

```dart
import 'package:flutter/painting.dart';

final RegExp _hexRegex = RegExp(r'^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$');

/// Parses a hex string like `#AABBCC` or `FF112233` into a [Color].
///
/// - 6 hex chars → opaque RGB with alpha forced to 0xFF.
/// - 8 hex chars → ARGB.
/// - Leading `#` optional; case-insensitive.
/// - Returns null for any other length or non-hex characters.
Color? parseHex(String input) {
  if (!_hexRegex.hasMatch(input)) return null;
  final cleaned = input.startsWith('#') ? input.substring(1) : input;
  final value = int.parse(cleaned, radix: 16);
  if (cleaned.length == 6) {
    return Color(0xFF000000 | value);
  }
  return Color(value);
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
fvm flutter test test/color_hex_parser_test.dart
```

Expected: `+7: All tests passed!`

- [ ] **Step 5: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/color_hex_parser.dart tuner/test/color_hex_parser_test.dart
git commit -m "feat(tuner): add color_hex_parser with unit tests"
```

---

## Task 10: color_hex_input widget

**Files:**
- Create: `tuner/lib/src/controls/color_hex_input.dart`

- [ ] **Step 1: Write the widget**

Create `tuner/lib/src/controls/color_hex_input.dart`:

```dart
import 'package:flutter/material.dart';

import '../color_hex_parser.dart';

/// Inline color editor: optional enabled checkbox → swatch → hex TextField.
///
/// - If [nullable] is true, a leading checkbox toggles the color on/off and
///   calls `onChanged(null)` when unchecked.
/// - Hex validation happens in real time; invalid input keeps the last
///   committed value and marks the field errored.
class ColorHexInput extends StatefulWidget {
  final String label;
  final Color? value;
  final ValueChanged<Color?> onChanged;
  final bool nullable;

  const ColorHexInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.nullable = false,
  });

  @override
  State<ColorHexInput> createState() => _ColorHexInputState();
}

class _ColorHexInputState extends State<ColorHexInput> {
  late final TextEditingController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _hexOf(widget.value));
  }

  @override
  void didUpdateWidget(covariant ColorHexInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isFocused()) {
      _controller.text = _hexOf(widget.value);
    }
  }

  bool _isFocused() => false; // Simplification: always sync on external update.

  String _hexOf(Color? c) {
    if (c == null) return '';
    final v = c.toARGB32();
    return v.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.value != null || !widget.nullable;
    return Row(
      children: [
        if (widget.nullable)
          Checkbox(
            value: widget.value != null,
            onChanged: (on) {
              if (on == true) {
                widget.onChanged(const Color(0xFF000000));
              } else {
                widget.onChanged(null);
              }
            },
          ),
        SizedBox(
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: widget.value ?? const Color(0xFFFFFFFF),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixText: '#',
              errorText: _hasError ? 'invalid hex' : null,
            ),
            onChanged: (text) {
              final parsed = parseHex(text);
              if (parsed == null) {
                setState(() => _hasError = true);
                return;
              }
              setState(() => _hasError = false);
              widget.onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: No issues. If `Color.toARGB32` isn't available on the bundled Flutter version, substitute with `c.value` (deprecated but works on 3.32). Pick the one that analyzer accepts.

- [ ] **Step 3: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/controls/color_hex_input.dart
git commit -m "feat(tuner): add ColorHexInput control (swatch + hex field + nullable)"
```

---

## Task 11: corner_picker

**Files:**
- Create: `tuner/lib/src/controls/corner_picker.dart`

- [ ] **Step 1: Write corner_picker**

Create `tuner/lib/src/controls/corner_picker.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Picker for corner presets sharp/xs/sm/md/lg/xl, plus a "custom" mode
/// with a single depth slider (0..6) applied symmetrically to all corners.
class CornerPicker extends StatefulWidget {
  final PixelCorners value;
  final ValueChanged<PixelCorners> onChanged;

  const CornerPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CornerPicker> createState() => _CornerPickerState();
}

class _CornerPickerState extends State<CornerPicker> {
  static const _presets = <String, PixelCorners>{
    'sharp': PixelCorners.sharp,
    'xs': PixelCorners.xs,
    'sm': PixelCorners.sm,
    'md': PixelCorners.md,
    'lg': PixelCorners.lg,
    'xl': PixelCorners.xl,
  };

  String _selected = 'lg';
  int _customDepth = 3;

  @override
  void initState() {
    super.initState();
    _syncFromValue();
  }

  @override
  void didUpdateWidget(covariant CornerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _syncFromValue();
  }

  void _syncFromValue() {
    for (final entry in _presets.entries) {
      if (identical(widget.value, entry.value) || widget.value == entry.value) {
        _selected = entry.key;
        return;
      }
    }
    _selected = 'custom';
  }

  PixelCorners _customCorners(int depth) {
    if (depth <= 0) return PixelCorners.sharp;
    final pattern = List.generate(depth, (i) => depth - i);
    return PixelCorners.all(pattern);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ..._presets.entries.map(
              (e) => _PresetButton(
                label: e.key,
                selected: _selected == e.key,
                onTap: () {
                  setState(() => _selected = e.key);
                  widget.onChanged(e.value);
                },
              ),
            ),
            _PresetButton(
              label: 'custom',
              selected: _selected == 'custom',
              onTap: () {
                setState(() => _selected = 'custom');
                widget.onChanged(_customCorners(_customDepth));
              },
            ),
          ],
        ),
        if (_selected == 'custom') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('depth'),
              Expanded(
                child: Slider(
                  value: _customDepth.toDouble(),
                  min: 0,
                  max: 6,
                  divisions: 6,
                  label: '$_customDepth',
                  onChanged: (v) {
                    setState(() => _customDepth = v.round());
                    widget.onChanged(_customCorners(_customDepth));
                  },
                ),
              ),
              SizedBox(width: 24, child: Text('$_customDepth')),
            ],
          ),
        ],
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5A8A3A) : const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF2A2A2A),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: `No issues found!`. If `PixelCorners.all(List<int>)` signature is different (e.g., takes a positional int or named pattern), consult `lib/src/pixel_corners.dart` and adapt. Same for the preset constants (`.xs`/`.sm`/`.md`/`.lg`/`.xl` must exist as static accessors).

- [ ] **Step 3: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/controls/corner_picker.dart
git commit -m "feat(tuner): add CornerPicker with presets + custom depth slider"
```

---

## Task 12: border_width_slider

**Files:**
- Create: `tuner/lib/src/controls/border_width_slider.dart`

- [ ] **Step 1: Write the widget**

Create `tuner/lib/src/controls/border_width_slider.dart`:

```dart
import 'package:flutter/material.dart';

/// 0–4 int border width slider; disables when [hasBorderColor] is false.
class BorderWidthSlider extends StatelessWidget {
  final int value;
  final bool hasBorderColor;
  final ValueChanged<int> onChanged;

  const BorderWidthSlider({
    super.key,
    required this.value,
    required this.hasBorderColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 60, child: Text('border')),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 4,
            divisions: 4,
            label: '$value',
            onChanged: hasBorderColor ? (v) => onChanged(v.round()) : null,
          ),
        ),
        SizedBox(width: 24, child: Text('$value')),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add tuner/lib/src/controls/border_width_slider.dart
git commit -m "feat(tuner): add BorderWidthSlider (disabled when no border color)"
```

---

## Task 13: shadow_editor

**Files:**
- Create: `tuner/lib/src/controls/shadow_editor.dart`

- [ ] **Step 1: Write shadow_editor**

Create `tuner/lib/src/controls/shadow_editor.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'color_hex_input.dart';

class ShadowEditor extends StatelessWidget {
  final PixelShadow? value;
  final ValueChanged<PixelShadow?> onChanged;

  const ShadowEditor({super.key, required this.value, required this.onChanged});

  static const _defaultColor = Color(0xFF1A3010);

  @override
  Widget build(BuildContext context) {
    final enabled = value != null;
    final dx = value?.offset.dx.toInt() ?? 1;
    final dy = value?.offset.dy.toInt() ?? 1;
    final color = value?.color ?? _defaultColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: enabled,
              onChanged: (on) {
                if (on == true) {
                  onChanged(
                    const PixelShadow(
                      offset: Offset(1, 1),
                      color: _defaultColor,
                    ),
                  );
                } else {
                  onChanged(null);
                }
              },
            ),
            const Text('shadow'),
            const SizedBox(width: 16),
            _PresetButton(
              label: 'sm',
              onTap: enabled
                  ? () => onChanged(PixelShadow(offset: const Offset(1, 1), color: color))
                  : null,
            ),
            _PresetButton(
              label: 'md',
              onTap: enabled
                  ? () => onChanged(PixelShadow(offset: const Offset(2, 2), color: color))
                  : null,
            ),
            _PresetButton(
              label: 'lg',
              onTap: enabled
                  ? () => onChanged(PixelShadow(offset: const Offset(4, 4), color: color))
                  : null,
            ),
          ],
        ),
        if (enabled) ...[
          _IntSlider(
            label: 'dx',
            value: dx,
            min: -3,
            max: 3,
            onChanged: (v) => onChanged(
              PixelShadow(offset: Offset(v.toDouble(), dy.toDouble()), color: color),
            ),
          ),
          _IntSlider(
            label: 'dy',
            value: dy,
            min: -3,
            max: 3,
            onChanged: (v) => onChanged(
              PixelShadow(offset: Offset(dx.toDouble(), v.toDouble()), color: color),
            ),
          ),
          ColorHexInput(
            label: 'shadow color',
            value: color,
            onChanged: (c) {
              if (c == null) return;
              onChanged(PixelShadow(offset: Offset(dx.toDouble(), dy.toDouble()), color: c));
            },
          ),
        ],
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: onTap == null ? const Color(0xFFDDDDDD) : const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _IntSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _IntSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.end)),
      ],
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/controls/shadow_editor.dart
git commit -m "feat(tuner): add ShadowEditor (enabled + presets + dx/dy + color)"
```

---

## Task 14: texture_editor

**Files:**
- Create: `tuner/lib/src/controls/texture_editor.dart`

- [ ] **Step 1: Write texture_editor**

Create `tuner/lib/src/controls/texture_editor.dart`:

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'color_hex_input.dart';

class TextureEditor extends StatefulWidget {
  final PixelTexture? value;
  final ValueChanged<PixelTexture?> onChanged;

  const TextureEditor({super.key, required this.value, required this.onChanged});

  @override
  State<TextureEditor> createState() => _TextureEditorState();
}

class _TextureEditorState extends State<TextureEditor> {
  final _rng = math.Random();

  static const _defaultColor = Color(0xFF000000);

  PixelTexture _default() =>
      const PixelTexture(density: 0.3, size: 1, seed: 0, color: _defaultColor);

  @override
  Widget build(BuildContext context) {
    final t = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: t != null,
              onChanged: (on) {
                widget.onChanged(on == true ? _default() : null);
              },
            ),
            const Text('texture'),
          ],
        ),
        if (t != null) ...[
          _DoubleSlider(
            label: 'density',
            value: t.density,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (v) => widget.onChanged(
              PixelTexture(density: v, size: t.size, seed: t.seed, color: t.color),
            ),
          ),
          _IntSlider(
            label: 'size',
            value: t.size,
            min: 1,
            max: 4,
            onChanged: (v) => widget.onChanged(
              PixelTexture(density: t.density, size: v, seed: t.seed, color: t.color),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _IntSlider(
                  label: 'seed',
                  value: t.seed,
                  min: 0,
                  max: 100,
                  onChanged: (v) => widget.onChanged(
                    PixelTexture(density: t.density, size: t.size, seed: v, color: t.color),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.casino),
                tooltip: 'random seed',
                onPressed: () => widget.onChanged(
                  PixelTexture(
                    density: t.density,
                    size: t.size,
                    seed: _rng.nextInt(101),
                    color: t.color,
                  ),
                ),
              ),
            ],
          ),
          ColorHexInput(
            label: 'texture color',
            value: t.color,
            onChanged: (c) {
              if (c == null) return;
              widget.onChanged(
                PixelTexture(density: t.density, size: t.size, seed: t.seed, color: c),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _DoubleSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _DoubleSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end)),
      ],
    );
  }
}

class _IntSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _IntSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.end)),
      ],
    );
  }
}
```

NOTE: verify `PixelTexture` constructor parameter names and types match (`density: double, size: int, seed: int, color: Color`). Consult `lib/src/pixel_texture.dart` if analyze complains.

- [ ] **Step 2: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/controls/texture_editor.dart
git commit -m "feat(tuner): add TextureEditor (density/size/seed/color + random button)"
```

---

## Task 15: Wire controls into home_page

**Files:**
- Modify: `tuner/lib/src/home_page.dart`

- [ ] **Step 1: Replace _ControlsPanel with real control cards**

In `tuner/lib/src/home_page.dart`, locate the `_ControlsPanel` class and replace it with:

```dart
class _ControlsPanel extends StatelessWidget {
  final TunerState state;
  const _ControlsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PixelShapeStyle>(
      valueListenable: state,
      builder: (context, style, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PixelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PixelSectionHeader('CORNERS'),
                    CornerPicker(
                      value: style.corners,
                      onChanged: state.setCorners,
                    ),
                  ],
                ),
              ),
              PixelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PixelSectionHeader('COLORS'),
                    ColorHexInput(
                      label: 'fill',
                      value: style.fillColor,
                      onChanged: (c) {
                        if (c != null) state.setFillColor(c);
                      },
                    ),
                    const SizedBox(height: 8),
                    ColorHexInput(
                      label: 'border',
                      value: style.borderColor,
                      nullable: true,
                      onChanged: state.setBorderColor,
                    ),
                    const SizedBox(height: 8),
                    BorderWidthSlider(
                      value: style.borderWidth,
                      hasBorderColor: style.borderColor != null,
                      onChanged: state.setBorderWidth,
                    ),
                  ],
                ),
              ),
              PixelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PixelSectionHeader('SHADOW'),
                    ShadowEditor(
                      value: style.shadow,
                      onChanged: state.setShadow,
                    ),
                  ],
                ),
              ),
              PixelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PixelSectionHeader('TEXTURE'),
                    TextureEditor(
                      value: style.texture,
                      onChanged: state.setTexture,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

Also add the corresponding imports at the top of `home_page.dart`:

```dart
import 'controls/border_width_slider.dart';
import 'controls/color_hex_input.dart';
import 'controls/corner_picker.dart';
import 'controls/shadow_editor.dart';
import 'controls/texture_editor.dart';
```

- [ ] **Step 2: Analyze**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Run in chrome and smoke-test every control**

Run:
```bash
fvm flutter run -d chrome
```

Verify:
- Corner preset buttons change the preview's corners
- "custom" reveals the depth slider
- Fill color hex field updates preview fill
- Border checkbox on/off adds/removes the border in preview and code
- Border width slider disabled when border color is off
- Shadow checkbox + presets + dx/dy move the shadow
- Texture checkbox + sliders apply the checker texture; 🎲 changes the pattern
- No console errors

- [ ] **Step 4: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/home_page.dart
git commit -m "feat(tuner): wire 5 controls into home_page ControlsPanel"
```

---

## Task 16: code_generator (TDD)

**Files:**
- Create: `tuner/test/code_generator_test.dart`
- Create: `tuner/lib/src/code_generator.dart`

- [ ] **Step 1: Write failing tests**

Create `tuner/test/code_generator_test.dart`:

```dart
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/code_generator.dart';

void main() {
  group('generateCode', () {
    test('preset corners emit preset identifier', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final code = generateCode(style);
      expect(code, contains('corners: PixelCorners.lg,'));
      expect(code, contains('fillColor: Color(0xFF5A8A3A),'));
    });

    test('null borderColor omits both borderColor and borderWidth lines', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFFFFFFFF),
        borderWidth: 3, // should still be omitted because borderColor is null
      );
      final code = generateCode(style);
      expect(code, isNot(contains('borderColor:')));
      expect(code, isNot(contains('borderWidth:')));
    });

    test('null shadow omits shadow block entirely', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
      );
      expect(generateCode(style), isNot(contains('shadow:')));
    });

    test('shadow present emits nested block with offset and color', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
        shadow: PixelShadow(offset: Offset(2, -1), color: Color(0xFF123456)),
      );
      final code = generateCode(style);
      expect(code, contains('shadow: PixelShadow('));
      expect(code, contains('offset: Offset(2, -1),'));
      expect(code, contains('color: Color(0xFF123456),'));
    });

    test('output uses 2-space indent', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final code = generateCode(style);
      expect(code, startsWith('const style = PixelShapeStyle(\n  corners: '));
    });

    test('fillColor uses uppercase 8-digit hex with 0xFF prefix', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFFAABBCC),
      );
      expect(generateCode(style), contains('Color(0xFFAABBCC)'));
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter test test/code_generator_test.dart
```

Expected: compile failure (`generateCode` not defined).

- [ ] **Step 3: Write the generator**

Create `tuner/lib/src/code_generator.dart`:

```dart
import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Generates a Dart source snippet declaring a `const style = PixelShapeStyle(...)`
/// equivalent to the given [style]. Nullable fields are omitted when null.
String generateCode(PixelShapeStyle style) {
  final lines = <String>['const style = PixelShapeStyle('];

  lines.add('  corners: ${_corners(style.corners)},');
  lines.add('  fillColor: ${_color(style.fillColor)},');

  if (style.borderColor != null) {
    lines.add('  borderColor: ${_color(style.borderColor!)},');
    lines.add('  borderWidth: ${style.borderWidth},');
  }

  if (style.shadow != null) {
    final s = style.shadow!;
    lines.add('  shadow: PixelShadow(');
    lines.add('    offset: Offset(${s.offset.dx.toInt()}, ${s.offset.dy.toInt()}),');
    lines.add('    color: ${_color(s.color)},');
    lines.add('  ),');
  }

  if (style.texture != null) {
    final t = style.texture!;
    lines.add('  texture: PixelTexture(');
    lines.add('    density: ${t.density},');
    lines.add('    size: ${t.size},');
    lines.add('    seed: ${t.seed},');
    lines.add('    color: ${_color(t.color)},');
    lines.add('  ),');
  }

  lines.add(');');
  return lines.join('\n');
}

String _color(Color c) {
  final v = c.toARGB32();
  return 'Color(0x${v.toRadixString(16).toUpperCase().padLeft(8, '0')})';
}

String _corners(PixelCorners corners) {
  // Preset identity via object identity
  if (identical(corners, PixelCorners.sharp)) return 'PixelCorners.sharp';
  if (identical(corners, PixelCorners.xs)) return 'PixelCorners.xs';
  if (identical(corners, PixelCorners.sm)) return 'PixelCorners.sm';
  if (identical(corners, PixelCorners.md)) return 'PixelCorners.md';
  if (identical(corners, PixelCorners.lg)) return 'PixelCorners.lg';
  if (identical(corners, PixelCorners.xl)) return 'PixelCorners.xl';

  // Preset equality (in case copyWith created a new instance)
  if (corners == PixelCorners.sharp) return 'PixelCorners.sharp';
  if (corners == PixelCorners.xs) return 'PixelCorners.xs';
  if (corners == PixelCorners.sm) return 'PixelCorners.sm';
  if (corners == PixelCorners.md) return 'PixelCorners.md';
  if (corners == PixelCorners.lg) return 'PixelCorners.lg';
  if (corners == PixelCorners.xl) return 'PixelCorners.xl';

  // Custom (symmetric)
  final pattern = corners.topLeft;
  if (pattern.isEmpty) return 'PixelCorners.sharp';
  return 'PixelCorners.all([${pattern.join(', ')}])';
}
```

NOTE: The `_corners` helper assumes `PixelCorners` exposes `topLeft` as a `List<int>`. Consult `lib/src/pixel_corners.dart` to confirm the field name and type. Adapt the custom branch if the API differs.

- [ ] **Step 4: Run tests**

Run:
```bash
fvm flutter test test/code_generator_test.dart
```

Expected: `+6: All tests passed!`

- [ ] **Step 5: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/code_generator.dart tuner/test/code_generator_test.dart
git commit -m "feat(tuner): add code_generator with tests (preset detection, null omission)"
```

---

## Task 17: code_panel (dark bg + MulmaruMono + Copy button)

**Files:**
- Create: `tuner/lib/src/code_panel.dart`

- [ ] **Step 1: Write code_panel with dark theme + Copy**

Create `tuner/lib/src/code_panel.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'code_generator.dart';
import 'tuner_state.dart';
import 'widgets/pixel_section_header.dart';

/// Dark-themed code panel: PixelShapeStyle → Dart source + copy button.
///
/// Visual refinement R2: #1A1A1A background, #9CCC65 lime text, MulmaruMono font.
class CodePanel extends StatelessWidget {
  final TunerState state;
  const CodePanel({super.key, required this.state});

  static const _bgColor = Color(0xFF1A1A1A);
  static const _textColor = Color(0xFF9CCC65);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PixelSectionHeader('CODE'),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
          ),
          child: ValueListenableBuilder<PixelShapeStyle>(
            valueListenable: state,
            builder: (context, style, _) {
              final code = generateCode(style);
              return SelectableText(
                code,
                style: PixelText.mulmaruMono(
                  fontSize: 12,
                  color: _textColor,
                  height: 1.4,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: PixelButton(
            logicalWidth: 48,
            logicalHeight: 16,
            normalStyle: const PixelShapeStyle(
              corners: PixelCorners.sm,
              fillColor: Color(0xFF5A8A3A),
              borderColor: Color(0xFF2A4820),
              borderWidth: 1,
              shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
            ),
            pressedStyle: const PixelShapeStyle(
              corners: PixelCorners.sm,
              fillColor: Color(0xFF4A7530),
              borderColor: Color(0xFF2A4820),
              borderWidth: 1,
            ),
            pressChildOffset: const Offset(0, 1),
            onPressed: () => _copy(context),
            child: Text(
              'COPY CODE',
              style: PixelText.mulmaru(
                fontSize: 12,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    final code = generateCode(state.value);
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied! Paste into your Dart source.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copy unavailable — select the code and use Cmd+C / Ctrl+C.'),
        ),
      );
    }
  }
}
```

- [ ] **Step 2: Wire CodePanel into home_page**

In `tuner/lib/src/home_page.dart`:

- Add import at top: `import 'code_panel.dart';`
- In `_WideLayout.build`, change the right side from:
  ```dart
  Expanded(
    flex: 70,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: PreviewPanel(state: state),
    ),
  ),
  ```
  to:
  ```dart
  Expanded(
    flex: 70,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PreviewPanel(state: state),
          CodePanel(state: state),
        ],
      ),
    ),
  ),
  ```
- In `_StackedLayout.build`, insert `CodePanel(state: state)` between `PreviewPanel` and the controls:
  ```dart
  children: [
    PreviewPanel(state: state),
    const SizedBox(height: 16),
    CodePanel(state: state),
    const SizedBox(height: 16),
    _ControlsPanel(state: state),
  ],
  ```

- [ ] **Step 3: Analyze + run**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter analyze
fvm flutter run -d chrome
```

Verify:
- Code panel shows the dark box with lime MulmaruMono text
- Text updates as controls change
- COPY CODE button copies to clipboard; SnackBar appears
- Paste into a scratch editor to verify the Dart code is valid and matches the preview

- [ ] **Step 4: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/lib/src/code_panel.dart tuner/lib/src/home_page.dart
git commit -m "feat(tuner): add code_panel with dark theme, MulmaruMono, and Copy button"
```

---

## Task 18: Responsive stacked smoke-test

**Files:** None modified — manual verification.

The stacked layout is already in place from Task 7 and extended in Task 17. This task just verifies it.

- [ ] **Step 1: Run in chrome and resize**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter run -d chrome
```

In Chrome DevTools, toggle responsive mode and set viewport width to 375px (iPhone size).

Verify:
- Layout stacks vertically: header → preview → code panel → controls
- No horizontal scroll
- All controls remain usable (no overlap, tap targets reachable)
- Preview scales to fit width (may appear smaller than 6x literal on narrow viewport — acceptable)

Resize back to desktop width (1200px+). Verify 30/70 layout returns cleanly.

- [ ] **Step 2: Fix any observed issues**

If the stacked layout overflows, wraps weirdly, or cuts off content, debug in the corresponding widget files and commit fixes like `fix(tuner): …`. Otherwise no commit needed.

---

## Task 19: web/index.html customization

**Files:**
- Modify: `tuner/web/index.html`

- [ ] **Step 1: Read current index.html**

Run:
```bash
cat /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner/web/index.html
```

Note the existing structure — Flutter's template has a `<title>`, `<meta name="description">`, `<meta name="theme-color">`, and favicon/manifest lines.

- [ ] **Step 2: Replace title, description, theme-color**

Edit `tuner/web/index.html`:
- Set `<title>` to `pixel_ui — PixelShapeStyle Tuner`
- Set `<meta name="description" content="Interactive tuner for pixel_ui — build a PixelShapeStyle visually and copy the generated Dart code.">`
- Set `<meta name="theme-color" content="#F5F1E8">`

Leave all other Flutter template lines (favicon, manifest, flutter_bootstrap.js loader) unchanged.

- [ ] **Step 3: Verify build still succeeds**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/tuner
fvm flutter build web --release --base-href /pixel_ui/
```

Expected: build succeeds, `tuner/build/web/index.html` contains the new title.

- [ ] **Step 4: Commit**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git add tuner/web/index.html
git commit -m "feat(tuner): customize web index title/description/theme-color"
```

---

## Task 20: deploy-tuner.yml workflow

**Files:**
- Create: `.github/workflows/deploy-tuner.yml`

- [ ] **Step 1: Write the workflow**

Create `.github/workflows/deploy-tuner.yml` with exactly this content:

```yaml
name: Deploy Tuner

on:
  push:
    branches: [main]
    paths:
      - 'tuner/**'
      - 'lib/**'
      - 'pubspec.yaml'
      - 'assets/**'
      - '.github/workflows/deploy-tuner.yml'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.7'
          channel: stable
      - name: Install dependencies
        working-directory: tuner
        run: flutter pub get
      - name: Analyze
        working-directory: tuner
        run: flutter analyze
      - name: Test
        working-directory: tuner
        run: flutter test
      - name: Build web
        working-directory: tuner
        run: flutter build web --release --base-href /pixel_ui/
      - name: Setup Pages
        uses: actions/configure-pages@v4
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: tuner/build/web
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 2: Validate YAML**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy-tuner.yml'))" && echo "YAML ok"
```

Expected: `YAML ok`

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy-tuner.yml
git commit -m "ci: add deploy-tuner workflow for GitHub Pages publishing"
```

---

## Task 21: README.md update (Live Tuner badge + link)

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add Live Tuner badge to the badge row**

Open `/Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/README.md`. Find the badges block near the top (below the `# pixel_ui` title):

```markdown
[![pub package](https://img.shields.io/pub/v/pixel_ui.svg)](https://pub.dev/packages/pixel_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

(There may be other badges — preserve them.) Append a new badge line:

```markdown
[![Live Tuner](https://img.shields.io/badge/Live-Tuner-5A8A3A.svg)](https://bottlepumpkin.github.io/pixel_ui/)
```

- [ ] **Step 2: Add a hero link below the tagline**

Find the tagline line under the badges (something like `Pixel-art design system for Flutter ...`). Insert a blank line after the tagline and add:

```markdown
**🎨 [Try the PixelShapeStyle tuner →](https://bottlepumpkin.github.io/pixel_ui/)**
```

- [ ] **Step 3: Verify**

Run:
```bash
grep -c "bottlepumpkin.github.io/pixel_ui" README.md
```

Expected: `2` (one in the badge, one in the hero link).

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs(README): add Live Tuner badge and hero link"
```

---

## Task 22: Push branch + open PR

**Files:** None modified — delivery step.

- [ ] **Step 1: Verify clean tree + commits ahead**

Run:
```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git status
git log --oneline origin/main..HEAD
```

Expected: clean tree, ~21 commits on feat/tuner.

- [ ] **Step 2: Push**

```bash
git push -u origin feat/tuner
```

- [ ] **Step 3: Open PR**

Run:
```bash
gh pr create --title "feat: Tuner web app for PixelShapeStyle (GitHub Pages)" --body "$(cat <<'EOF'
## Summary

Sibling Flutter web app at \`tuner/\` that lets users adjust a \`PixelShapeStyle\` via Material controls wrapped in pixel chrome, previews the result at 6x, and copies generated Dart code. Deploys to https://bottlepumpkin.github.io/pixel_ui/ via \`.github/workflows/deploy-tuner.yml\`.

- No changes to the published pixel_ui package (\`lib/\`, root \`pubspec.yaml\`).
- \`tuner/\` uses \`publish_to: none\` + \`pixel_ui: path ../\`.
- First use of the freshly-bundled \`MulmaruMono\` font (0.2.1) in the code panel.

**Specs:**
- \`docs/superpowers/specs/2026-04-23-tuner-design.md\` (visual refinements R1/R2/R3)
- \`docs/specs/2026-04-22-tuner-design.md\` (base structure + controls UX)

**Plan:** \`docs/superpowers/plans/2026-04-23-tuner-implementation.md\`

## Visual decisions

- **R1**: 30/70 layout with Preview+Code dominant, 6x PixelBox scale
- **R2**: Code panel dark (#1A1A1A) with lime MulmaruMono (#9CCC65)
- **R3**: PixelCard layered border (2px outer + 1px inset highlight, NES.css-style)

## Manual action required before first deploy

On https://github.com/BottlePumpkin/pixel_ui/settings/pages, set **Source** to **"GitHub Actions"**. One-time setup per repo.

## Test plan

- [x] \`flutter analyze\` (tuner) clean
- [x] \`flutter test\` (tuner): color_hex_parser + code_generator + tuner_state unit tests pass
- [x] Smoke-tested every control in chrome (corners preset/custom, colors, border, shadow, texture)
- [x] Stacked layout at 375px viewport
- [x] COPY CODE → clipboard + SnackBar
- [ ] Post-merge: Pages Source enabled, \`deploy-tuner.yml\` green, https://bottlepumpkin.github.io/pixel_ui/ loads with Mulmaru font rendering and no console errors

## Out of scope (0.2+ roadmap)

- Per-side asymmetric corners
- Dark theme toggle, preview zoom
- URL-encoded style sharing
- Full-pixel form controls (PixelSlider, PixelTextField)
EOF
)"
```

Expected: PR URL printed.

- [ ] **Step 4: Report PR URL and wait for merge decision**

Do NOT attempt to enable Pages or trigger deploy before the PR merges. User will review + merge.

---

## Task 23: Post-merge — enable Pages + validate deploy

**Files:** None modified — deployment verification.

**Prerequisite:** PR from Task 22 merged to main.

- [ ] **Step 1: Sync local main**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git checkout main
git pull --ff-only origin main
```

- [ ] **Step 2: Enable GitHub Pages Source (user action, one-time)**

Ask the user to:
1. Visit https://github.com/BottlePumpkin/pixel_ui/settings/pages
2. Under **Source**, select **"GitHub Actions"**
3. Save

Wait for user confirmation before proceeding.

- [ ] **Step 3: Trigger deploy**

The merge to main will typically trigger `deploy-tuner.yml` via the path filter automatically (because `tuner/**` changed). If it didn't, or if it ran before Pages was enabled, trigger manually:

```bash
gh workflow run deploy-tuner.yml --ref main
```

Expected: workflow queued.

- [ ] **Step 4: Watch workflow**

```bash
gh run watch
```

Expected: all steps green (checkout → flutter setup → pub get → analyze → test → build web → setup Pages → upload artifact → deploy).

If any step fails, investigate via `gh run view --log-failed` and file a fix commit on a new branch.

- [ ] **Step 5: Verify deployed site**

Visit https://bottlepumpkin.github.io/pixel_ui/ in a browser. Check:

- [ ] Page loads within 5 seconds
- [ ] Title bar shows `pixel_ui — PixelShapeStyle Tuner`
- [ ] Mulmaru font renders in headers and `PixelSectionHeader`
- [ ] Preview panel shows green/brown PixelBox at 6x on checker background
- [ ] Code panel shows dark background + lime MulmaruMono text
- [ ] All 5 control sections interactive; preview + code update live
- [ ] Border on/off toggle hides/shows border lines in code
- [ ] COPY CODE copies to clipboard; SnackBar appears
- [ ] DevTools Console: no errors
- [ ] Resize to 375px: stacked layout works

- [ ] **Step 6: Report completion**

Summarize:
- PR merged, deploy workflow green
- Live URL verified
- Any residual polish items noted for follow-up

This closes the Tuner project.
