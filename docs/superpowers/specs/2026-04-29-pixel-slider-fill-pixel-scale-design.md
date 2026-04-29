# PixelSlider Fill Pixel-Scale Fix Design

**Date:** 2026-04-29
**Branch:** `fix/pixel-slider-fill-pixel-scale`
**Scope:** `lib/src/pixel_slider.dart` (production fix) + new goldens (regression guard).

## Problem

`PixelSlider` 의 fill `PixelBox` 가 **트랙과 다른 per-pixel 스케일** 로 렌더되어, 부모가 자연 크기(`trackLogicalWidth × 4 dp`, 기본 320dp) 보다 좁거나 넓을 때 보더·코너 픽셀이 어긋난다.

### 재현
- tuner 의 SliderPreview (AspectRatio 안에 들어가 가변 폭)
- 슬라이더 값을 작은 쪽으로 끌면 fill 의 픽셀 크기가 매우 작아져 트랙의 큰 픽셀과 시각적으로 불일치 (보더 두께·코너 모양 다름)
- 값을 키우면 fillDpW 가 trackDpW 에 근접해 perPxW 가 자연 일치 → 정상 보임

### 원인
`pixel_slider.dart:130-138` 에서 fill 박스가:
- `logicalWidth: widget.trackLogicalWidth` (예: 80)
- `width: fillDpW` (값에 비례, 작아질 수 있음)

→ fill 의 `perPxW = fillDpW / 80` 가 매우 작아짐. 트랙은 같은 80 logical 을 더 큰 dp 폭에 그리므로 `perPxW = trackDpW / 80` 큼. 두 박스의 logical pixel 한 칸이 다른 dp 크기로 그려지면서 시각적 mismatch 발생.

## Fix

fill 의 `logicalWidth` 를 fill 폭에 비례해 계산해서 fill 과 트랙의 `perPxW` 를 일치시킨다.

### 변경 위치
`lib/src/pixel_slider.dart` 의 `_PixelSliderState.build()` 안 LayoutBuilder 빌더 (line 102-217 부근).

### 변경 내용
```dart
// 기존 (line 130-138)
Positioned(
  left: 0,
  top: trackTopOffset,
  width: fillDpW,
  height: trackDpH,
  child: PixelBox(
    style: fill!,
    logicalWidth: widget.trackLogicalWidth,   // ← 트랙과 동일한 80 (버그)
    logicalHeight: widget.trackLogicalHeight,
    width: fillDpW,
    height: trackDpH,
  ),
),

// 변경 후
final fillLogicalW =
    (widget.trackLogicalWidth * fillDpW / trackDpW).round().clamp(
      1,
      widget.trackLogicalWidth,
    );
// ...
Positioned(
  left: 0,
  top: trackTopOffset,
  width: fillDpW,
  height: trackDpH,
  child: PixelBox(
    style: fill!,
    logicalWidth: fillLogicalW,                // ← fill 폭에 비례
    logicalHeight: widget.trackLogicalHeight,
    width: fillDpW,
    height: trackDpH,
  ),
),
```

### Edge cases
- `value == min` → `fillDpW = thumbDp` (예: 32dp). `trackDpW = 320` 일 때 `fillLogicalW = round(80 × 32 / 320) = 8` → perPxW = 32/8 = 4dp ✓ (트랙 perPxW = 320/80 = 4dp 와 일치)
- `value == max` → `fillDpW = trackDpW` → `fillLogicalW = trackLogicalWidth` ✓
- `trackDpW == 0` 가능성: `LayoutBuilder` 가 0폭을 줄 수 있음. `fillDpW = 0` 이면 0/0 NaN 위험 → `clamp(1, ...)` 가 가드. 단 `trackDpW = 0` 자체는 division-by-zero 발생 → 가드 추가 (`if (trackDpW <= 0)` early return 0).
- 반올림 1 logical pixel 차이로 fill 가장자리가 thumb 중심과 미세하게 어긋날 수 있으나 사용자 인지 한계 이하 (≤ perPxW/2 ≈ 2dp).

### Non-goals
- 트랙 자체가 부모 폭에 맞춰 stretch 되는 동작은 그대로 유지 (별도 issue).
- thumb 의 logical 처리는 변경 없음 (정사각형, `logicalWidth = thumbLogicalSize`).
- PixelBox 의 다른 사용처에는 영향 없음.

## Regression guard (goldens)

기존 골든 (`test/goldens/pixel_slider/value_*.png`) 은 `SizedBox(width: 320)` 자연 크기를 사용해 perPxW 가 우연히 일치 → 버그 노출 안 됨.

**새 골든 추가 (3개):**
- `narrow_value_0.png` — width=200dp (비-자연), value=0
- `narrow_value_half.png` — width=200dp, value=0.5
- `narrow_value_1.png` — width=200dp, value=1.0

200dp 선택 이유: trackLogicalWidth=80 의 비-정수 배수 (200/80=2.5 dp/logical pixel). 반올림 동작이 노출됨.

기존 골든 5개는 변경 없이 그대로 통과해야 함 (자연 크기에서는 `fillLogicalW == trackLogicalWidth` 라 동일 결과).

## Tests

`test/pixel_slider_golden_test.dart` 에 다음 추가:

```dart
Widget _frameNarrow({required Widget slider}) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF1B1F2A),
      body: Center(
        child: SizedBox(
          width: 200,                          // ← 비-자연 폭
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

testWidgets('narrow width=200, value=0', ...);
testWidgets('narrow width=200, value=0.5', ...);
testWidgets('narrow width=200, value=1.0', ...);
```

**골든 생성:** `fvm flutter test test/pixel_slider_golden_test.dart --update-goldens` 후 PNG 검증 (육안으로 fill·track 픽셀 정렬 확인) → 커밋.

**CI:** `.github/workflows/test.yml` 은 `--exclude-tags screenshot` 로 골든 제외 (CLAUDE.md 메모리 참조). 골든은 painter goldens 정책에 따라 회귀 가드 역할만, CI 차단 안 함.

## Out of scope (별 follow-up)

- **Tuner E2E 테스트 (marionette MCP):** 사이드바 dispatch / preview slider 드래그 시 fill 정렬 — `ValueKey` 추가 + marionette 스크립트 별 이슈로 분리.
- **PixelSlider stretch vs fixed-natural 정책:** 부모 폭이 자연 크기보다 클 때 트랙을 stretch 할지 자연 크기로 둘지는 별도 디자인 논의 필요.

## File touch list

| File | Action |
|---|---|
| `lib/src/pixel_slider.dart` | Modify (fillLogicalW 계산 + fill PixelBox 인자) |
| `test/pixel_slider_golden_test.dart` | Add `_frameNarrow` + 3 testWidgets |
| `test/goldens/pixel_slider/narrow_value_0.png` | Create (--update-goldens) |
| `test/goldens/pixel_slider/narrow_value_half.png` | Create (--update-goldens) |
| `test/goldens/pixel_slider/narrow_value_1.png` | Create (--update-goldens) |
| `CHANGELOG.md` | Add `## Unreleased` entry (fix: PixelSlider fill pixel scale) |

## Verification checklist

- [ ] `fvm flutter analyze` clean
- [ ] `fvm flutter test --exclude-tags screenshot` 모든 통과
- [ ] `fvm flutter test test/pixel_slider_golden_test.dart` 신규 3개 + 기존 5개 모두 pass
- [ ] tuner 수동 검증: `cd tuner && fvm flutter run -d chrome` → SliderPreview 의 fill 픽셀이 다양한 값에서 트랙과 정렬됨
