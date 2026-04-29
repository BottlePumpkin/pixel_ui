# PixelSlider Fill Pixel-Scale Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix `PixelSlider` so its fill `PixelBox` renders at the same per-logical-pixel scale as the track, eliminating the visual mismatch that appears whenever the slider is laid out at a width other than the natural `trackLogicalWidth × 4 dp`.

**Architecture:** Extract a tiny pure helper (`fillLogicalWidthFor`) that computes fill's `logicalWidth` proportional to its dp width vs the track's dp width. Unit-test the helper (TDD). Wire it into `_PixelSliderState.build()`. Add narrow-width golden tests at `width=200dp` (a non-natural, non-integer-multiple width) as regression guard — existing 320dp goldens are unchanged because at the natural width `fillLogicalW == trackLogicalWidth`.

**Tech Stack:** Dart 3.8 / Flutter SDK 3.32+. `flutter/material.dart`, `flutter_test`. No new deps.

**Spec reference:** `docs/superpowers/specs/2026-04-29-pixel-slider-fill-pixel-scale-design.md` (commit `cb6926f`).

---

## File Structure

| File | Purpose | Action |
|---|---|---|
| `lib/src/pixel_slider.dart` | Add top-level `fillLogicalWidthFor` pure function; use it in fill PixelBox `logicalWidth` arg | Modify |
| `test/pixel_slider_test.dart` | Add unit tests for `fillLogicalWidthFor` | Modify |
| `test/pixel_slider_golden_test.dart` | Add `_frameNarrow(width:)` helper + 3 narrow-width testWidgets | Modify |
| `test/goldens/pixel_slider/narrow_value_0.png` | Regression golden at width=200dp, value=0 | Create |
| `test/goldens/pixel_slider/narrow_value_half.png` | Regression golden at width=200dp, value=0.5 | Create |
| `test/goldens/pixel_slider/narrow_value_1.png` | Regression golden at width=200dp, value=1.0 | Create |
| `CHANGELOG.md` | `## Unreleased > ### Fixed` entry | Modify |

---

## Task 1: Extract `fillLogicalWidthFor` helper + unit tests

**Files:**
- Modify: `lib/src/pixel_slider.dart` (add top-level function)
- Modify: `test/pixel_slider_test.dart` (add unit tests)

- [ ] **Step 1: Read the existing test file head to confirm imports + test style**

```bash
head -30 /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/test/pixel_slider_test.dart
```

Expected: confirm `package:flutter_test/flutter_test.dart` and `package:pixel_ui/pixel_ui.dart` are imported. We'll add to the existing `main()` at the bottom (in a new `group(...)` if convenient).

- [ ] **Step 2: Append the failing unit tests**

Add to `test/pixel_slider_test.dart` — at the bottom of the existing `main()` body (before the closing `}` of `main`):

```dart
  group('fillLogicalWidthFor', () {
    test('value=min (fillDp == thumbDp) at natural track width', () {
      // trackLogicalWidth=80 → trackDpW=320 (natural). thumbDp=32 → fillDp=32.
      // Expected: 80 * 32 / 320 = 8 logical pixels (matches thumb).
      expect(
        fillLogicalWidthFor(
          trackLogicalWidth: 80,
          fillDp: 32,
          trackDp: 320,
        ),
        8,
      );
    });

    test('value=max (fillDp == trackDp) returns trackLogicalWidth', () {
      expect(
        fillLogicalWidthFor(
          trackLogicalWidth: 80,
          fillDp: 320,
          trackDp: 320,
        ),
        80,
      );
    });

    test('value=half at narrow track (200dp) rounds proportionally', () {
      // Natural would be 80 * 176 / 320 = 44 — but here track is 200dp.
      // ratio=0.5: thumbLeft=(200-32)*0.5=84, fillDp=84+32=116.
      // expected fillLogicalW = round(80 * 116 / 200) = round(46.4) = 46.
      expect(
        fillLogicalWidthFor(
          trackLogicalWidth: 80,
          fillDp: 116,
          trackDp: 200,
        ),
        46,
      );
    });

    test('clamps to 1 when fillDp/trackDp ratio rounds below 1', () {
      // trackLogicalWidth=80, fillDp=1, trackDp=200 → 80*1/200=0.4 → round=0
      // → clamped to 1.
      expect(
        fillLogicalWidthFor(
          trackLogicalWidth: 80,
          fillDp: 1,
          trackDp: 200,
        ),
        1,
      );
    });

    test('clamps to trackLogicalWidth when fillDp exceeds trackDp', () {
      // Defensive: fillDp shouldn't exceed trackDp in practice, but guard.
      expect(
        fillLogicalWidthFor(
          trackLogicalWidth: 80,
          fillDp: 999,
          trackDp: 200,
        ),
        80,
      );
    });

    test('returns 0 when trackDp == 0 (avoid division by zero)', () {
      expect(
        fillLogicalWidthFor(
          trackLogicalWidth: 80,
          fillDp: 0,
          trackDp: 0,
        ),
        0,
      );
    });
  });
```

- [ ] **Step 3: Run tests to verify compile-failure**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter test test/pixel_slider_test.dart
```

Expected: compile error like `The function 'fillLogicalWidthFor' isn't defined`.

- [ ] **Step 4: Implement the helper**

Add a top-level function near the top of `lib/src/pixel_slider.dart`, **after the imports and BEFORE the `class PixelSlider` declaration** (around line 7-8):

```dart
/// Computes the [PixelBox.logicalWidth] for the slider's fill, given
/// the track's logical width and the dp widths of fill and track.
///
/// The fill renders inside the slider track but its visible dp width
/// changes with `value`. Naively passing `trackLogicalWidth` to the fill
/// would mean each logical pixel of the fill is squeezed into a smaller
/// dp width than the track's, producing a visible mismatch in border
/// thickness and corner pixels at non-natural slider widths. This helper
/// scales the fill's logical width proportionally so that
/// `fillDp / fillLogicalWidth ≈ trackDp / trackLogicalWidth`,
/// keeping the per-logical-pixel dp size consistent across track and fill.
///
/// Edge cases:
/// - `trackDp <= 0` → returns `0` (caller should skip rendering).
/// - Result is clamped to `[1, trackLogicalWidth]` when `trackDp > 0`,
///   so a near-zero fill still produces a visible 1-pixel-wide box.
@visibleForTesting
int fillLogicalWidthFor({
  required int trackLogicalWidth,
  required double fillDp,
  required double trackDp,
}) {
  if (trackDp <= 0) return 0;
  final raw = (trackLogicalWidth * fillDp / trackDp).round();
  if (raw < 1) return 1;
  if (raw > trackLogicalWidth) return trackLogicalWidth;
  return raw;
}
```

Add the import at the top of `lib/src/pixel_slider.dart` if not already present:

```dart
import 'package:flutter/foundation.dart' show visibleForTesting;
```

- [ ] **Step 5: Run unit tests to verify they pass**

```bash
fvm flutter test test/pixel_slider_test.dart
```

Expected: all tests pass (existing tests + 6 new `fillLogicalWidthFor` cases).

- [ ] **Step 6: Run analyzer**

```bash
fvm flutter analyze
```

Expected: `No issues found!`.

- [ ] **Step 7: Commit**

```bash
git add lib/src/pixel_slider.dart test/pixel_slider_test.dart
git commit -m "feat(pixel-slider): add fillLogicalWidthFor helper + unit tests"
```

---

## Task 2: Wire `fillLogicalWidthFor` into `_PixelSliderState.build()`

**Files:**
- Modify: `lib/src/pixel_slider.dart:130-138` (fill PixelBox `logicalWidth` arg)

- [ ] **Step 1: Locate the fill PixelBox**

Open `lib/src/pixel_slider.dart` and find the `LayoutBuilder` body inside `_PixelSliderState.build()` — specifically the second `Positioned` (fill, currently at lines ~127-139):

```dart
Positioned(
  left: 0,
  top: trackTopOffset,
  width: fillDpW,
  height: trackDpH,
  child: PixelBox(
    style: fill!,
    logicalWidth: widget.trackLogicalWidth,   // ← BUG: same as track
    logicalHeight: widget.trackLogicalHeight,
    width: fillDpW,
    height: trackDpH,
  ),
),
```

- [ ] **Step 2: Replace `logicalWidth` with `fillLogicalWidthFor` call**

Just **above** the `Positioned` block above (immediately after `final fillDpW = thumbLeft + thumbDp;` on line 106), insert:

```dart
      final fillLogicalW = fillLogicalWidthFor(
        trackLogicalWidth: widget.trackLogicalWidth,
        fillDp: fillDpW,
        trackDp: trackDpW,
      );
```

Then change the fill `PixelBox` line from:

```dart
        logicalWidth: widget.trackLogicalWidth,
```

to:

```dart
        logicalWidth: fillLogicalW,
```

- [ ] **Step 3: Run analyzer**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter analyze
```

Expected: `No issues found!`.

- [ ] **Step 4: Run existing slider tests (sanity)**

```bash
fvm flutter test test/pixel_slider_test.dart
```

Expected: all existing tests still pass.

- [ ] **Step 5: Run existing slider goldens (must still match — natural 320dp width)**

```bash
fvm flutter test test/pixel_slider_golden_test.dart
```

Expected: all 5 existing goldens pass. **Reasoning:** at `trackDpW == 320` (natural), `fillLogicalW == round(80 * fillDpW / 320)`. For the existing test cases:
- value=0: fillDp=32, fillLogicalW=8. Old code rendered with logicalW=80 squeezed into 32dp → very different. **The existing value_0 golden may now drift!**

⚠️ If `value_0.png` (and possibly `discrete_step_2_of_5.png`) drift, that confirms the bug was visible even at the natural width — the existing goldens were baked WITH the bug. We need to regenerate them.

- [ ] **Step 6: Regenerate existing goldens to capture the corrected rendering**

```bash
fvm flutter test test/pixel_slider_golden_test.dart --update-goldens
```

Then visually inspect the regenerated PNGs:

```bash
ls -la test/goldens/pixel_slider/
```

Open each in an image viewer (e.g., `open test/goldens/pixel_slider/value_0.png`). Confirm:
- value_0: fill is a small 1-thumb-wide box with same border thickness as track (8 logical pixels wide × 4dp/pixel = 32dp).
- value_half: fill is half-width with consistent border.
- value_1: fill matches track exactly (visually merges, only thumb visible at right edge).
- discrete_*: same correctness check.

- [ ] **Step 7: Commit**

```bash
git add lib/src/pixel_slider.dart test/goldens/pixel_slider/
git commit -m "fix(pixel-slider): match fill per-pixel scale to track"
```

---

## Task 3: Add narrow-width regression goldens

**Files:**
- Modify: `test/pixel_slider_golden_test.dart` (add `_frameNarrow` + 3 testWidgets)
- Create: `test/goldens/pixel_slider/narrow_value_0.png`
- Create: `test/goldens/pixel_slider/narrow_value_half.png`
- Create: `test/goldens/pixel_slider/narrow_value_1.png`

- [ ] **Step 1: Add the narrow frame helper + 3 test cases**

Open `test/pixel_slider_golden_test.dart`. Below the existing `_frame` function (after the closing `}` of `_frame` around line 47), add:

```dart
Widget _frameNarrow({required Widget slider}) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF1B1F2A),
      body: Center(
        child: SizedBox(
          width: 200,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: slider,
            ),
          ),
        ),
      ),
    ),
  );
}
```

Inside `void main() { ... }`, after the existing test cases and **before** the closing `}` of `main`, add:

```dart
  testWidgets('narrow width=200, continuous value=0', (tester) async {
    await tester.pumpWidget(_frameNarrow(slider: _continuous(0)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/narrow_value_0.png'),
    );
  });

  testWidgets('narrow width=200, continuous value=0.5', (tester) async {
    await tester.pumpWidget(_frameNarrow(slider: _continuous(0.5)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/narrow_value_half.png'),
    );
  });

  testWidgets('narrow width=200, continuous value=1.0', (tester) async {
    await tester.pumpWidget(_frameNarrow(slider: _continuous(1.0)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/narrow_value_1.png'),
    );
  });
```

- [ ] **Step 2: Run, expect "missing golden file"**

```bash
fvm flutter test test/pixel_slider_golden_test.dart
```

Expected: 3 new tests fail with "Could not be compared against non-existent file: goldens/pixel_slider/narrow_value_*.png".

- [ ] **Step 3: Generate the goldens**

```bash
fvm flutter test test/pixel_slider_golden_test.dart --update-goldens
```

Expected: all tests pass; 3 new PNGs appear in `test/goldens/pixel_slider/`.

- [ ] **Step 4: Visually inspect new goldens**

```bash
open test/goldens/pixel_slider/narrow_value_0.png
open test/goldens/pixel_slider/narrow_value_half.png
open test/goldens/pixel_slider/narrow_value_1.png
```

Verify in each PNG:
- Track and fill have **the same border thickness** in pixels.
- Track and fill have **the same corner pixel pattern** (PixelCorners.sm rendered identically).
- No visible per-pixel scale discrepancy between track and fill.

If any look wrong, stop and re-investigate — the formula or the wiring may be off.

- [ ] **Step 5: Re-run goldens to confirm stable**

```bash
fvm flutter test test/pixel_slider_golden_test.dart
```

Expected: all 8 tests pass (5 existing + 3 new).

- [ ] **Step 6: Commit**

```bash
git add test/pixel_slider_golden_test.dart test/goldens/pixel_slider/narrow_value_0.png test/goldens/pixel_slider/narrow_value_half.png test/goldens/pixel_slider/narrow_value_1.png
git commit -m "test(pixel-slider): goldens at non-natural width=200 — regression guard"
```

---

## Task 4: CHANGELOG entry

**Files:**
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Add a `### Fixed` subsection under `## Unreleased`**

Open `CHANGELOG.md`. Find the `## Unreleased` block at the top. Below the existing `### Added` / `### Docs` / `### Internal` subsections (in the same `## Unreleased` block), add a new `### Fixed` subsection. Place it **after `### Internal`** to follow the existing ordering convention (Added → Docs → Internal → Fixed):

```markdown
### Fixed
- `PixelSlider` — fill no longer renders at a different per-pixel scale than the track when the slider is laid out at a width other than the natural `trackLogicalWidth × 4 dp` (default 320dp). Border thickness and corner pixels of the fill now match the track at any layout width. Adds `fillLogicalWidthFor` test helper and three regression goldens at `width=200dp` (`narrow_value_0` / `narrow_value_half` / `narrow_value_1`).
```

- [ ] **Step 2: Verify the file still passes the README-version check (unrelated, but cheap)**

```bash
fvm dart run tool/check_readme_version.dart
```

Expected: `✅ README pin ^0.5.0 covers pubspec 0.5.1.` (or whichever version is current).

- [ ] **Step 3: Commit**

```bash
git add CHANGELOG.md
git commit -m "chore: CHANGELOG — PixelSlider fill pixel-scale fix"
```

---

## Task 5: Final QA + push + PR

**Files:** none modified — verification only.

- [ ] **Step 1: Run analyzer (root)**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter analyze
```

Expected: `No issues found!`.

- [ ] **Step 2: Run full root test suite (excluding screenshot scenes)**

```bash
fvm flutter test --exclude-tags screenshot
```

Expected: all tests pass, no regressions outside `pixel_slider`.

- [ ] **Step 3: Run the slider-specific suites including goldens**

```bash
fvm flutter test test/pixel_slider_test.dart test/pixel_slider_golden_test.dart
```

Expected: all unit tests + 5 existing goldens + 3 new goldens pass.

- [ ] **Step 4: Manually smoke-test in the tuner**

```bash
cd tuner && fvm flutter run -d chrome
```

In the browser:
- Click `Slider` in the sidebar.
- Drag the preview slider's thumb across the full range.
- Confirm: at every position, the fill's border / corner pixels visually match the track's. No "shrinking pixels" artefact when the value is small.

If still mismatched, inspect:
1. Is `trackDpW` from `LayoutBuilder` what you expect? (Add a temporary `print(trackDpW)`.)
2. Is `fillLogicalW` an integer ≥ 1 and ≤ trackLogicalWidth?
3. Did `--update-goldens` pick up the corrected output? (`git status` should show no diff in pngs.)

Stop here and reopen brainstorming if the manual check disagrees with the goldens — that means the test setup doesn't reflect the real layout.

Quit the tuner with `q` in the terminal once verified.

- [ ] **Step 5: Push branch and open PR**

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
git push -u origin fix/pixel-slider-fill-pixel-scale
gh pr create --title "fix(pixel-slider): match fill per-pixel scale to track" --body "$(cat <<'EOF'
## 변경 사항

`PixelSlider` 의 fill `PixelBox` 가 트랙과 다른 per-logical-pixel 스케일로 렌더되어, 부모가 자연 크기(`trackLogicalWidth × 4 dp`, 기본 320dp) 와 다른 폭일 때 보더·코너 픽셀이 어긋나던 버그 수정.

### 원인
fill 의 `PixelBox` 가 `logicalWidth: trackLogicalWidth` (예: 80) + `width: fillDpW` 로 렌더 → fill 의 `perPxW = fillDpW / 80` 이 트랙의 `perPxW = trackDpW / 80` 와 다름.

### 수정
`fillLogicalWidthFor(trackLogicalWidth, fillDp, trackDp)` 순수 함수 추가 — fill 의 logical width 를 dp 폭에 비례해 산출. fill 과 트랙이 동일한 perPxW 로 렌더됨.

### 검증
- `fvm flutter analyze` clean
- `fvm flutter test --exclude-tags screenshot` 모든 통과
- 슬라이더 골든 8개 (기존 5 + 신규 3 narrow_value_*) 모두 pass
- tuner SliderPreview 수동 검증: 모든 값 위치에서 fill 픽셀이 트랙과 정렬

### Out of scope (별 follow-up 가능)
- Tuner E2E 자동화 (marionette MCP) — sidebar dispatch / preview drag fill 정렬 검증은 ValueKey 부착 + marionette 스크립트 필요, 별 이슈로 분리 권장
- PixelSlider 의 자연 크기 vs stretch 정책 자체는 변경 없음 (별도 디자인 논의)

### Spec / plan
- `docs/superpowers/specs/2026-04-29-pixel-slider-fill-pixel-scale-design.md`
- `docs/superpowers/plans/2026-04-29-pixel-slider-fill-pixel-scale.md`
EOF
)"
```

Expected: PR opens, CI starts. URL printed to terminal.

- [ ] **Step 6: Watch CI**

```bash
gh pr view --json statusCheckRollup
```

Expected: `Test` (analyze + test + dry-run) and `Platform Build Matrix` all SUCCESS.

If any check fails, click through the URL, fix root cause, push another commit. Do not merge until green.

- [ ] **Step 7: Stop here — wait for user review/merge.**

Do not auto-merge. Report PR URL back to the user.

---

## Self-Review Checklist (engineer should NOT skip — applied during plan authoring)

Spec coverage:
- ✅ Spec "Fix" section → Task 1 (helper + tests) + Task 2 (wire it in)
- ✅ Spec "Regression guard (goldens)" → Task 3
- ✅ Spec "Tests" → Task 1 unit tests + Task 3 goldens
- ✅ Spec "File touch list" → matches the table at the top of this plan + CHANGELOG (Task 4) + verification (Task 5)
- ✅ Spec "Verification checklist" → Task 5 Step 1-4

Placeholders: none.

Type consistency:
- `fillLogicalWidthFor({required int trackLogicalWidth, required double fillDp, required double trackDp}) → int` is consistent across Task 1 (definition + tests) and Task 2 (call site).
- Golden file names (`narrow_value_0`, `narrow_value_half`, `narrow_value_1`) are consistent in Task 3 + Task 4 + Task 5 PR body.
