# Test CI Job + PixelShapePainter Unit Goldens — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `test.yml` GitHub Actions workflow that runs `analyze + test + dry-run` on every PR/push, and create a 12-case unit golden suite for `PixelShapePainter` that catches per-feature pixel regressions.

**Architecture:** Two physically separate workflows (`test.yml` for fast package validation on Ubuntu, existing `build.yml` for slow platform-build matrix). One new test file `test/shape_painter_golden_test.dart` with `@Tags(['golden'])` and golden artifacts under `test/goldens/painter/`. Baseline generated on `ubuntu-latest` (matches CI runner) so local macOS is best-effort.

**Tech Stack:** Flutter `3.32.7` (matches existing `build.yml`), `flutter_test` golden APIs, GitHub Actions, `subosito/flutter-action@v2`.

**Spec:** `docs/specs/2026-04-23-test-ci-and-painter-goldens-design.md`

**Commit identity (CRITICAL):** All commits must use `BottlePumpkin <p4569zz@gmail.com>`. Do NOT add Claude/AI attribution to any commit message or trailer (per `.claude/projects/-Users-byeonghopark-jobis-dev-byeonghopark-pixel-ui/memory/feedback_commit_style.md`).

---

## Task 1: Create `test.yml` workflow

**Files:**
- Create: `.github/workflows/test.yml`

- [ ] **Step 1: Write the workflow file**

Write `.github/workflows/test.yml`:

```yaml
name: Test

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    name: Analyze + Test + Publish dry-run
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.7'
          channel: 'stable'
      - name: Pub get (root package)
        run: flutter pub get
      - name: Analyze (package)
        run: flutter analyze
      - name: Test (package)
        run: flutter test
      - name: Publish dry-run
        run: dart pub publish --dry-run
      - name: Pub get (example)
        run: flutter pub get
        working-directory: example
      - name: Analyze (example)
        run: flutter analyze
        working-directory: example
```

- [ ] **Step 2: Validate YAML locally**

Run:
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/test.yml'))" && echo "YAML OK"
```
Expected: `YAML OK`

- [ ] **Step 3: Smoke-test the steps locally**

Run each command sequentially from repo root and confirm none currently fail:

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm dart pub publish --dry-run
(cd example && fvm flutter pub get && fvm flutter analyze)
```

Expected: every command exits 0. `dart pub publish --dry-run` may print warnings but must not error. If anything fails, stop and surface — the CI jobs would also fail.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/test.yml
git commit -m "ci: add test workflow for analyze + test + publish dry-run"
```

---

## Task 2: Add Test badge to README

**Files:**
- Modify: `README.md` (top of file, badge row at lines 3–5)

- [ ] **Step 1: Insert Test badge after the existing Platform Build badge**

Locate the badge block at the top of `README.md`:

```markdown
[![pub package](https://img.shields.io/pub/v/pixel_ui.svg)](https://pub.dev/packages/pixel_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform Build](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml)
```

Replace with:

```markdown
[![pub package](https://img.shields.io/pub/v/pixel_ui.svg)](https://pub.dev/packages/pixel_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Test](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml)
[![Platform Build](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml)
```

The Test badge appears before Platform Build because test results are the more frequent signal.

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs(readme): add Test workflow badge"
```

---

## Task 3: Create golden test file with first case (TDD scaffold)

This task establishes the test file structure with one case (`corners_md`) end-to-end before scaling to all 12. The pattern:
1. Write the test referencing a golden file that does not yet exist.
2. Run test → it fails because no baseline.
3. Generate baseline with `--update-goldens`.
4. Re-run → passes.
5. Visually inspect the PNG before commit.

**Files:**
- Create: `test/shape_painter_golden_test.dart`
- Create (via `--update-goldens`): `test/goldens/painter/corners_md.png`

- [ ] **Step 1: Write the failing test**

Write `test/shape_painter_golden_test.dart`:

```dart
@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _fill = Color(0xFF00FF00);
const _border = Color(0xFF003300);
const _shadowColor = Color(0xFF222222);
const _textureColor = Color(0xFF003300);

Future<void> _pumpBox(WidgetTester tester, PixelShapeStyle style) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: PixelBox(
          logicalWidth: 16,
          logicalHeight: 16,
          style: style,
        ),
      ),
    ),
  );
}

void main() {
  group('PixelShapePainter goldens', () {
    testWidgets('corners md', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_md.png'),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails (no baseline yet)**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: FAIL with a message like `Could not be compared against non-existent file: ".../goldens/painter/corners_md.png"`. This confirms the test wiring is correct.

- [ ] **Step 3: Generate the baseline**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden --update-goldens
```
Expected: PASS (1 test). The file `test/goldens/painter/corners_md.png` is created.

- [ ] **Step 4: Visually inspect the generated golden**

Open `test/goldens/painter/corners_md.png` in any image viewer. Confirm it shows a green (0xFF00FF00) 64×64 square with dark green (0xFF003300) 1-px border and `md` stair-pattern corners (3-row stair on each corner). If it looks wrong, stop — the test code is at fault, not the golden infrastructure.

- [ ] **Step 5: Run again without `--update-goldens` to confirm stability**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: PASS. This confirms the comparison loop works.

- [ ] **Step 6: Confirm `flutter test` (no tags) also runs the golden**

Run:
```bash
fvm flutter test
```
Expected: all tests pass, including the new `corners md` case (golden tags do NOT exclude by default; they only add a tag for opt-in via `--tags`/opt-out via `--exclude-tags`).

- [ ] **Step 7: Commit**

```bash
git add test/shape_painter_golden_test.dart test/goldens/painter/corners_md.png
git commit -m "test: add PixelShapePainter golden harness (corners md baseline)"
```

---

## Task 4: Add remaining 5 corner cases

**Files:**
- Modify: `test/shape_painter_golden_test.dart`
- Create (via `--update-goldens`): 5 PNGs under `test/goldens/painter/`

- [ ] **Step 1: Add the 5 corner cases to the test file**

Inside `group('PixelShapePainter goldens', () { ... })`, after the existing `corners md` test, add:

```dart
    testWidgets('corners sharp', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.sharp,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_sharp.png'),
      );
    });

    testWidgets('corners xs', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.xs,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_xs.png'),
      );
    });

    testWidgets('corners sm', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.sm,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_sm.png'),
      );
    });

    testWidgets('corners lg', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.lg,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_lg.png'),
      );
    });

    testWidgets('corners xl', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.xl,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_xl.png'),
      );
    });
```

- [ ] **Step 2: Run failing tests (no baselines yet)**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 5 new tests FAIL with "non-existent file" errors; `corners md` still PASS.

- [ ] **Step 3: Generate baselines**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden --update-goldens
```
Expected: 6 tests PASS. Five new PNGs appear under `test/goldens/painter/`.

- [ ] **Step 4: Visually inspect each new golden**

Open each new PNG in `test/goldens/painter/` and confirm:
- `corners_sharp.png`: square, no rounding (4 sharp 90° corners)
- `corners_xs.png`: 1-pixel cut on each corner
- `corners_sm.png`: 2-row stair on each corner
- `corners_lg.png`: 4-row stair (with flattened inner row at index 2,3) on each corner
- `corners_xl.png`: 6-row smooth stair on each corner

If any look wrong, stop and investigate the test code or `PixelCorners` definitions.

- [ ] **Step 5: Re-run to confirm stability**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 6 PASS.

- [ ] **Step 6: Commit**

```bash
git add test/shape_painter_golden_test.dart test/goldens/painter/corners_sharp.png test/goldens/painter/corners_xs.png test/goldens/painter/corners_sm.png test/goldens/painter/corners_lg.png test/goldens/painter/corners_xl.png
git commit -m "test: add PixelShapePainter goldens for all corner presets"
```

---

## Task 5: Add 3 shadow cases

**Files:**
- Modify: `test/shape_painter_golden_test.dart`
- Create (via `--update-goldens`): 3 PNGs under `test/goldens/painter/`

- [ ] **Step 1: Append shadow cases to the test file**

Inside the same `group(...)`, append:

```dart
    testWidgets('shadow sm', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.sm(_shadowColor),
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/shadow_sm.png'),
      );
    });

    testWidgets('shadow md', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.md(_shadowColor),
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/shadow_md.png'),
      );
    });

    testWidgets('shadow lg', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.lg(_shadowColor),
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/shadow_lg.png'),
      );
    });
```

Note on physical size: the shadow path in `PixelBox` extends the rendered `SizedBox` by `shadow.offset.abs() * (physicalPx / logicalPx)` per axis. With logicalWidth=16 and default size=64 physical (4× per logical), `PixelShadow.sm` (offset 1,1) gives 68×68; `md` (2,2) gives 72×72; `lg` (4,4) gives 80×80. `find.byType(PixelBox)` captures the full SizedBox including shadow padding, so the golden will show the box plus its drop shadow.

- [ ] **Step 2: Run failing tests**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 3 new tests FAIL with "non-existent file"; previous 6 PASS.

- [ ] **Step 3: Generate baselines**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden --update-goldens
```
Expected: 9 tests PASS.

- [ ] **Step 4: Visually inspect**

Open each shadow PNG and confirm a dark grey (0xFF222222) drop shadow appears down-and-right of the green box, with stair offset of 1/2/4 logical pixels (= 4/8/16 physical pixels at 4× scale).

- [ ] **Step 5: Re-run to confirm stability**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 9 PASS.

- [ ] **Step 6: Commit**

```bash
git add test/shape_painter_golden_test.dart test/goldens/painter/shadow_sm.png test/goldens/painter/shadow_md.png test/goldens/painter/shadow_lg.png
git commit -m "test: add PixelShapePainter goldens for shadow factories"
```

---

## Task 6: Add texture on/off cases

**Files:**
- Modify: `test/shape_painter_golden_test.dart`
- Create (via `--update-goldens`): 2 PNGs

- [ ] **Step 1: Append texture cases**

Append to the `group(...)`:

```dart
    testWidgets('texture off', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/texture_off.png'),
      );
    });

    testWidgets('texture on', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          texture: PixelTexture(
            color: _textureColor,
            density: 0.15,
            size: 1,
            seed: 42,
          ),
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/texture_on.png'),
      );
    });
```

Note: `texture_off` is intentionally similar to `corners_md` but kept as a separate file for symmetry with `texture_on` (so the diff between the two PNGs is precisely "texture present"). `PixelTexture` is deterministic via LCG seed=42, so the pattern is stable across builds and platforms.

- [ ] **Step 2: Run failing tests**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 2 new tests FAIL; previous 9 PASS.

- [ ] **Step 3: Generate baselines**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden --update-goldens
```
Expected: 11 tests PASS.

- [ ] **Step 4: Visually inspect**

- `texture_off.png`: identical to `corners_md.png` (clean green box, md corners, dark green border, no noise).
- `texture_on.png`: same shape but with sparse dark green pixels scattered inside (~15% density).

If both look identical, the `PixelTexture` is not painting — investigate.

- [ ] **Step 5: Re-run to confirm stability**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 11 PASS.

- [ ] **Step 6: Commit**

```bash
git add test/shape_painter_golden_test.dart test/goldens/painter/texture_off.png test/goldens/painter/texture_on.png
git commit -m "test: add PixelShapePainter goldens for texture on/off"
```

---

## Task 7: Add asymmetric corners case

**Files:**
- Modify: `test/shape_painter_golden_test.dart`
- Create (via `--update-goldens`): 1 PNG

- [ ] **Step 1: Append asymmetric case**

Append to the `group(...)`. Two corners use a 3-row stair, the other two are sharp. This exercises the asymmetric-path code (different corner depths per corner) which uniform `PixelCorners.all(...)` does not:

```dart
    testWidgets('asymmetric tabs (top-left + bottom-right)', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.only(
            tl: [3, 2, 1],
            tr: [],
            bl: [],
            br: [3, 2, 1],
          ),
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/asymmetric_tabs.png'),
      );
    });
```

- [ ] **Step 2: Run failing test**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 1 new test FAILs; previous 11 PASS.

- [ ] **Step 3: Generate baseline**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden --update-goldens
```
Expected: 12 tests PASS.

- [ ] **Step 4: Visually inspect**

Open `asymmetric_tabs.png` and confirm:
- Top-left and bottom-right corners have a 3-row stair (rounded).
- Top-right and bottom-left corners are sharp 90°.

If all four corners look identical, the test code didn't apply asymmetry — investigate.

- [ ] **Step 5: Re-run to confirm stability**

Run:
```bash
fvm flutter test test/shape_painter_golden_test.dart --tags golden
```
Expected: 12 PASS.

- [ ] **Step 6: Final full test run (no tags filter)**

Run:
```bash
fvm flutter test
```
Expected: all tests pass, including all 12 goldens. This is what CI will run.

- [ ] **Step 7: Commit**

```bash
git add test/shape_painter_golden_test.dart test/goldens/painter/asymmetric_tabs.png
git commit -m "test: add PixelShapePainter golden for asymmetric corners"
```

---

## Task 8: Verify CI integration end-to-end

This task pushes to a feature branch (or main) and inspects GitHub Actions to confirm the new `test.yml` runs and the goldens are validated remotely.

**Files:** none (verification only)

- [ ] **Step 1: Push to remote**

If working on main:
```bash
git push origin main
```

If working on a branch (recommended for verification):
```bash
git push -u origin HEAD
```

- [ ] **Step 2: Check workflow runs**

Run:
```bash
gh run list --workflow=test.yml --limit=1
```
Expected: a recent run is listed. Wait for it to complete:
```bash
gh run watch
```

- [ ] **Step 3: Confirm test job passed**

Run:
```bash
gh run view --log | grep -E "(✓|✗|FAIL|PASS|All tests passed|Some tests failed)" | head -30
```
Expected: `Test (package)` step shows all tests passing (12 goldens + existing tests). If any golden fails on Linux, the local baseline was generated on a non-Linux platform — regenerate baselines on a Linux environment (e.g., a temporary `act` run, Docker, or push a commit with `--update-goldens` enabled in a temporary CI step) and re-commit.

- [ ] **Step 4: Confirm Test badge renders**

Open https://github.com/BottlePumpkin/pixel_ui in a browser and confirm both badges (Test, Platform Build) render with the expected status colors (green = passing). The Test badge URL is `https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml/badge.svg`.

- [ ] **Step 5: No commit needed for this task** (verification only)

---

## Risks & Rollback

- **If goldens fail on CI (Linux) but pass locally (macOS):** the baseline was generated on macOS. Fix: re-run `flutter test --tags golden --update-goldens` inside a Linux environment (Docker `dart:stable` image with Flutter, or a temporary CI workflow step), pull the regenerated PNGs, commit them.
- **If `dart pub publish --dry-run` fails on CI:** likely a `.pubignore` regression or new file added that conflicts with package layout. Inspect the error log and fix in a follow-up commit; the workflow will re-run.
- **If example `flutter analyze` fails:** likely a transient lint introduced in example code. Fix or suppress in `example/analysis_options.yaml`.

This work does NOT change the published package (no `lib/` change, no version bump). To roll back entirely: revert the commits and push. No pub.dev impact.

---

## Spec coverage check

| Spec section | Implementing task(s) |
|---|---|
| §3.1 Form decision (separate `test.yml`) | Task 1 |
| §3.2 Workflow structure | Task 1, Step 1 |
| §3.3 Step intent | Task 1, Step 3 (smoke test) |
| §3.4 README badges | Task 2 |
| §4.1 File locations | Task 3 |
| §4.2 12-case matrix | Tasks 3 (1) + 4 (5) + 5 (3) + 6 (2) + 7 (1) = 12 |
| §4.3 16×16 logical | Task 3 (`_pumpBox` helper) |
| §4.4 OS-bias handling (`@Tags(['golden'])`, Linux baseline) | Task 3, Step 1; Task 8 |
| §4.5 Test file skeleton | Task 3 |
| §4.6 CI integration | Task 1 + Task 8 |
| §6 Order (A1 → A2) | Task 1 → Tasks 3–7 |
| §7 Impact (no `lib/` change, no version bump) | Verified by structure of all tasks |
