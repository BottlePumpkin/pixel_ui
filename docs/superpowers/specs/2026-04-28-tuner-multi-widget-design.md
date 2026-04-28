# Tuner Multi-Widget Refactor — Design Spec

**작성일:** 2026-04-28
**이슈:** #59
**대상:** `tuner/` (현 단일-`PixelShapeStyle` 편집기 → 다중 위젯 playground)
**비-목표:** pixel_ui 본 패키지 변경, pub.dev 배포 (`tuner/` 는 `publish_to: none`)

---

## 1. 맥락

### 1.1 현재 구조

`tuner/` 는 v0.1 시점 (`docs/specs/2026-04-22-tuner-design.md`) 에 `PixelShapeStyle` 단일 편집기로 설계됨:

- `TunerState extends ValueNotifier<PixelShapeStyle>` — 단일 스타일 추적
- `PreviewPanel` — 단일 `PixelBox` 프리뷰 (체커 배경)
- `CodePanel` + `code_generator.dart` — 단일 `PixelShapeStyle` const emit
- `HomePage` — 와이드 2-column / 내로우 stacked, 단일 `_ControlsPanel`

### 1.2 새 요구

Cycle #3 fast-track 직후 `PixelSwitch` (PR #57, 4 styles) 와 `PixelSlider` (PR #58, 4 styles + min/max/divisions) 가 머지됨. 두 PR 모두 description 에서 *"Tuner playground 패널 별 PR follow-up"* 으로 명시. 이 spec 은 그 follow-up 의 architectural design.

### 1.3 확장성 요구

PixelButton / PixelListTile / PixelGrid 등 미래 위젯도 같은 tuner 에 들어와야 함. 추상화는 만들되 이번 PR 에서는 Switch + Slider 까지만 실제 구현.

---

## 2. 핵심 결정 (architectural)

| # | 결정 | 선택 | 이유 |
|---|---|---|---|
| Q1 | 네비게이션 모델 | **사이드바 (Hybrid: NavigationRail wide / Drawer narrow)** | 위젯 set 장기 확장 (10+) 대비. 사이드바 항목은 `PixelListTile` 로 dogfooding. |
| Q2 | 상태 아키텍처 | **Per-widget state objects (독립)** | 현 ValueNotifier 패턴 유지. 새 위젯 추가가 클래스 1개. 위젯 간 격리 자연. |
| Q3 | 추상화 인터페이스 | **`WidgetTuner` 추상 클래스 + per-widget folder** | 명시적 컨트랙트, type-safe registry, `tuners[i].buildControls()` 디스패치. |
| Q4 | 코드 생성 | **Style consts + Widget call (full snippet)** | 기존 패턴 자연 확장. Copy-paste 친화. README cookbook 과 일치. |
| Q5 | `check_tuner_coverage` | **현 동작 보존 + grep 경로 1줄 패치 (orphan scope: controls 만, missing scope: tuner/lib/src 전체)** | 이번 PR 스코프 집중. 위젯-fields coverage 는 별도 follow-up. |
| Q6 | 사이드바 chrome | **Hybrid: Material `NavigationRail`/`Drawer` + 항목은 `PixelListTile`** | Material 이 chrome (애니메이션/포커스/접근성) 를 무료. 항목은 픽셀 정체성. |

---

## 3. 디렉터리 구조

### 3.1 신규/이동 파일

```
tuner/lib/src/
├── home_page.dart                       (수정 — sidebar + 활성 tuner 디스패치)
├── widget_tuner.dart                    (신규 — abstract WidgetTuner)
├── widgets/
│   ├── _shared/
│   │   ├── style_section.dart           (신규 — 4 controls 묶음 wrapper)
│   │   ├── nullable_style_section.dart  (신규 — 토글 + StyleSection)
│   │   ├── style_codegen.dart           (신규 — 공통 emitStyleConst/_color/_corners)
│   │   └── code_view.dart               (이동 — 구 code_panel 의 chrome)
│   ├── box/
│   │   ├── box_tuner.dart               (BoxWidgetTuner)
│   │   ├── box_state.dart               (구 tuner_state.dart 의 본체)
│   │   ├── box_controls.dart            (구 _ControlsPanel 의 box 부분)
│   │   ├── box_preview.dart             (구 preview_panel.dart)
│   │   └── box_code.dart                (구 code_generator.dart 의 PixelShapeStyle 단일 emit + paired usage)
│   ├── switch/
│   │   ├── switch_tuner.dart
│   │   ├── switch_state.dart            (4 styles + previewValue)
│   │   ├── switch_controls.dart
│   │   ├── switch_preview.dart
│   │   └── switch_code.dart
│   └── slider/
│       ├── slider_tuner.dart
│       ├── slider_state.dart            (4 styles + min/max/divisions/previewValue)
│       ├── slider_controls.dart
│       ├── slider_preview.dart
│       └── slider_code.dart
├── controls/                            (그대로 유지 — 재사용 sub-controls)
│   ├── color_hex_input.dart
│   ├── corner_picker.dart
│   ├── border_width_slider.dart
│   ├── shadow_editor.dart
│   ├── texture_editor.dart
│   └── label_editor.dart
└── widgets/                             (기존 leaf widgets 유지)
    ├── pixel_card.dart
    └── pixel_section_header.dart
```

### 3.2 삭제 파일

- `tuner/lib/src/tuner_state.dart` → `widgets/box/box_state.dart` 로 이동
- `tuner/lib/src/preview_panel.dart` → `widgets/box/box_preview.dart` 로 이동
- `tuner/lib/src/code_panel.dart` → 분해: chrome → `widgets/_shared/code_view.dart`, Box-specific 코드 emit → `widgets/box/box_code.dart`
- `tuner/lib/src/code_generator.dart` → 분해: 공통 `_color`/`_corners`/`emitStyleConst` → `widgets/_shared/style_codegen.dart`, Box paired usage → `widgets/box/box_code.dart`

---

## 4. 핵심 추상화: `WidgetTuner`

```dart
// tuner/lib/src/widget_tuner.dart
abstract class WidgetTuner {
  /// 사이드바·헤더에 표시되는 위젯 이름. e.g. 'PixelBox', 'PixelSwitch'.
  String get name;

  /// NavigationRail destination + Drawer leading 에 사용되는 16×16 logical
  /// 픽셀 아이콘. 위젯 정체성을 PixelBox 합성으로 추상화.
  Widget get pixelIcon;

  /// 컨트롤 패널 (와이드: 가운데 컬럼, 내로우: 하단).
  Widget buildControls(BuildContext context);

  /// 프리뷰 패널 (와이드: 우측 상단, 내로우: 상단).
  Widget buildPreview(BuildContext context);

  /// 코드 패널 (와이드: 우측 하단, 내로우: 가운데).
  Widget buildCode(BuildContext context);

  /// 라이프사이클 정리 — 내부 ValueNotifier/ChangeNotifier dispose.
  void dispose();
}
```

각 widget tuner module 은 `<Widget>State` 를 자기 인스턴스로 보유 + `build*` 메서드 안에서 자기 상태에 listen.

### 4.1 등록

```dart
// home_page.dart
typedef WidgetTunerFactory = WidgetTuner Function();

final List<WidgetTunerFactory> _factories = [
  () => BoxWidgetTuner(),
  () => SwitchWidgetTuner(),
  () => SliderWidgetTuner(),
];

// Lazy-init: 처음 선택될 때 생성, 이후 재사용
final List<WidgetTuner?> _tuners = List.filled(_factories.length, null);

WidgetTuner _ensure(int i) => _tuners[i] ??= _factories[i]();
```

`HomePage.dispose()` 에서 모든 `non-null _tuners[i]` 에 대해 `.dispose()` 호출.

---

## 5. 위젯별 상태 모델

### 5.1 Box (`box_state.dart`)

기존 `TunerState` 본체 그대로 이동. 시그니처 변경 없음:

```dart
class BoxState extends ValueNotifier<PixelShapeStyle> {
  BoxState() : super(_initial);
  static const _initial = PixelShapeStyle(
    corners: PixelCorners.lg,
    fillColor: Color(0xFF5A8A3A),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
    shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
  );

  final ValueNotifier<String?> labelText = ValueNotifier(null);

  void setCorners(PixelCorners c)   => value = value.copyWith(corners: c);
  void setFillColor(Color c)        => value = value.copyWith(fillColor: c);
  void setBorderColor(Color? c)     => value = value.copyWith(borderColor: c);
  void setBorderWidth(int w)        => value = value.copyWith(borderWidth: w);
  void setShadow(PixelShadow? s)    => value = value.copyWith(shadow: s);
  void setTexture(PixelTexture? t)  => value = value.copyWith(texture: t);
  void setLabel(String? text) {
    final trimmed = (text == null || text.isEmpty) ? null : text;
    labelText.value = trimmed;
  }

  @override
  void dispose() { labelText.dispose(); super.dispose(); }
}
```

### 5.2 Switch (`switch_state.dart`)

```dart
class SwitchState extends ChangeNotifier {
  PixelShapeStyle onTrack = _defaultOnTrack;
  PixelShapeStyle offTrack = _defaultOffTrack;
  PixelShapeStyle thumb = _defaultThumb;
  PixelShapeStyle? disabledStyle;       // optional
  bool previewValue = false;

  void setOnTrack(PixelShapeStyle s)    { onTrack = s; notifyListeners(); }
  void setOffTrack(PixelShapeStyle s)   { offTrack = s; notifyListeners(); }
  void setThumb(PixelShapeStyle s)      { thumb = s; notifyListeners(); }
  void setDisabled(PixelShapeStyle? s)  { disabledStyle = s; notifyListeners(); }
  void togglePreviewValue()             { previewValue = !previewValue; notifyListeners(); }

  // Defaults align with the README cookbook recipe.
  static const _defaultOnTrack = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFFFFD643),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
  );
  static const _defaultOffTrack = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF555E73),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );
  static const _defaultThumb = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFFFFFFFF),
  );
}
```

### 5.3 Slider (`slider_state.dart`)

```dart
class SliderState extends ChangeNotifier {
  PixelShapeStyle track = _defaultTrack;
  PixelShapeStyle fill = _defaultFill;
  PixelShapeStyle thumb = _defaultThumb;
  PixelShapeStyle? disabledStyle;
  double min = 0.0;
  double max = 1.0;
  int? divisions;                       // null = continuous
  double previewValue = 0.5;

  void setTrack(PixelShapeStyle s)      { track = s; notifyListeners(); }
  void setFill(PixelShapeStyle s)       { fill = s; notifyListeners(); }
  void setThumb(PixelShapeStyle s)      { thumb = s; notifyListeners(); }
  void setDisabled(PixelShapeStyle? s)  { disabledStyle = s; notifyListeners(); }
  void setMin(double v) {
    min = v;
    previewValue = previewValue.clamp(min, max);
    notifyListeners();
  }
  void setMax(double v) {
    max = v;
    previewValue = previewValue.clamp(min, max);
    notifyListeners();
  }
  void setDivisions(int? n)             { divisions = n; notifyListeners(); }
  void setPreviewValue(double v)        { previewValue = v.clamp(min, max); notifyListeners(); }

  static const _defaultTrack = PixelShapeStyle(
    corners: PixelCorners.sm, fillColor: Color(0xFF222732),
    borderColor: Color(0xFF12141A), borderWidth: 1);
  static const _defaultFill = PixelShapeStyle(
    corners: PixelCorners.sm, fillColor: Color(0xFFFFD643),
    borderColor: Color(0xFF2A4820), borderWidth: 1);
  static const _defaultThumb = PixelShapeStyle(
    corners: PixelCorners.sm, fillColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFF12141A), borderWidth: 1);
}
```

---

## 6. UI 레이아웃

### 6.1 Wide (>720dp) — 3-column

```
┌────────────────────────────────────────────────────────────────────────┐
│ Header (full width — pixel)                                            │
│ PIXEL UI TUNER                                                          │
├──────────┬──────────────────────────┬──────────────────────────────────┤
│ Rail     │ Controls (flex 30)       │ Preview + Code (flex 70)         │
│ ──────   │                          │ ┌─ PREVIEW ──────────────────┐  │
│ ▣ Box    │ [active widget controls] │ │ (live)                     │  │
│ ◐ Switch │                          │ └────────────────────────────┘  │
│ ━ Slider │                          │ ┌─ CODE ─────────────────────┐  │
│          │                          │ │ const ... = ...            │  │
│ ──────   │                          │ │ ...                        │  │
│ (soon)   │                          │ │ [COPY CODE]                │  │
│ Button   │                          │ └────────────────────────────┘  │
│ ListTile │                          │                                  │
│ Grid     │                          │                                  │
└──────────┴──────────────────────────┴──────────────────────────────────┘
   80dp        flex 30                    flex 70
```

- **NavigationRail**: Material 위젯, `extended=false` (80dp) 기본. 상단에 토글 (extended=true → 200dp 라벨 노출). 배경 `#22232E`. 선택 인디케이터: 좌측 4px 컬러 바.
- "soon" 항목 (Button/ListTile/Grid): `enabled: false` 시각, 클릭 시 SnackBar `"Coming soon"`. Rail 의 `disabled` 시각 직접 구현 (NavigationRailDestination 자체는 disabled 미지원이라 wrapping 필요) 또는 별도 ListView 영역으로 분리.

### 6.2 Narrow (≤720dp) — Drawer + Stacked

```
┌──────────────────────────────────────┐
│ ☰  PIXEL UI TUNER · Switch          │   ← 햄버거 + 현재 위젯 라벨
├──────────────────────────────────────┤
│  ┌─ PREVIEW ──────────────────────┐  │
│  └────────────────────────────────┘  │
│  ┌─ CODE ─────────────────────────┐  │
│  └────────────────────────────────┘  │
│  ┌─ Controls ─────────────────────┐  │
│  │   (collapsible PixelCards)     │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘

햄버거 → Drawer:
┌────────────────┐
│ TUNER          │
│ ──────────────  │
│ ☐ Box      ●  │  ← PixelListTile, leading=픽셀아이콘, trailing=선택 dot
│ ☐ Switch       │
│ ☐ Slider       │
│ ──────────────  │
│ ☐ Button (soon)│  ← enabled=false, tap → SnackBar
│ ☐ ListTile ··  │
│ ☐ Grid ··      │
└────────────────┘
```

Drawer 의 각 항목은 `PixelListTile` 사용 (dogfooding). `onTap` → `_selectedIndex.value = i; Navigator.pop(context);`.

### 6.3 픽셀 아이콘 (위젯 정체성)

각 widget tuner 의 `pixelIcon` 은 16×16 logical PixelBox 합성:

- **Box**: 단일 `PixelBox(corners: md, fillColor: accent)` — 패널
- **Switch**: 가로 트랙 (16×6) + 우측 thumb (4×4)
- **Slider**: 가로 트랙 (16×2) + 중앙 thumb (4×4)
- **Button (soon)**: `PixelCorners.sharp` + 그림자
- **ListTile (soon)**: 가로 행 + 좌측 leading 사각형
- **Grid (soon)**: 2×2 작은 사각형

각 아이콘은 `<name>_tuner.dart` 안에 inline `Widget _buildIcon()` 함수로.

---

## 7. 컨트롤 패널 — `StyleSection` 추상화

4-style 위젯 (Switch / Slider) 이 반복되는 컨트롤 그룹을 가지므로 신규 컴포넌트:

```dart
// tuner/lib/src/widgets/_shared/style_section.dart
class StyleSection extends StatelessWidget {
  final String title;                  // "ON TRACK", "FILL", etc.
  final PixelShapeStyle value;
  final ValueChanged<PixelShapeStyle> onChanged;
  final bool collapsedByDefault;
  // 내부: PixelCard + PixelSectionHeader + 5 sub-controls
  //   (corners / fillColor / borderColor+borderWidth / shadow / texture)
  //   - 기존 controls/* 위젯 재사용
}

class NullableStyleSection extends StatelessWidget {
  final String title;
  final PixelShapeStyle? value;
  final ValueChanged<PixelShapeStyle?> onChanged;
  // 토글 (on/off) + on 일 때 StyleSection 임베드
}
```

### 7.1 Switch controls layout

- ON TRACK — `StyleSection` (default expanded)
- OFF TRACK — `StyleSection(collapsedByDefault: true)`
- THUMB — `StyleSection(collapsedByDefault: true)`
- DISABLED — `NullableStyleSection`
- PREVIEW VALUE — Material `Switch` 1개 (`state.previewValue` ↔ 양방향 binding) — 라이브 토글로 슬라이딩 애니메이션 시연

### 7.2 Slider controls layout

- TRACK / FILL / THUMB — 각 `StyleSection`
- DISABLED — `NullableStyleSection`
- RANGE — 신규 `RangeSection`:
  - `min` — Material `TextField(keyboardType: number)` 또는 `Slider`
  - `max` — 동일
  - `divisions` — Material `TextField` + checkbox `[continuous]` (체크 시 `setDivisions(null)`)
- PREVIEW VALUE — Material `Slider` (현 min/max/divisions 적용) ↔ `state.previewValue` 양방향

### 7.3 Box controls layout (변경 최소)

기존 `_ControlsPanel` 의 Box 섹션 그대로:
- CORNERS / COLORS / SHADOW / TEXTURE / LABEL

리팩토링 기회: Box 의 corners+colors+shadow+texture 도 `StyleSection` 으로 통일 가능. 단, Box 는 LABEL 이라는 widget-level 추가 prop 이 있어 `StyleSection` + 별도 LABEL `PixelCard` 로 합성. 본 PR 범위에서는 Box 코드 변경을 최소화하기 위해 기존 `_ControlsPanel` 구조 그대로 `BoxControls` 클래스로 이동 (단순 rename + 분리).

---

## 8. Preview 패널

각 widget tuner 의 `buildPreview()` 가 자기 PreviewPanel 위젯 반환. 공통:

- 체커보드 배경 (`_CheckerPainter` 재사용 — `widgets/_shared/checker_painter.dart` 로 이동)
- 와이드: aspectRatio 2:1, scale 6×
- 내로우: aspectRatio 그대로, 부모 폭 따라 자동 축소

### 8.1 Box preview (기존 그대로)

`PixelBox(logicalWidth: 80, logicalHeight: 24, scale: 6, style: state.value, label: state.labelText)` — 기존 동작 그대로.

### 8.2 Switch preview

```
┌─ checkerboard ──────────────────┐
│                                 │
│       [PixelSwitch live]        │   logical 24×12, scale 6× → 144×72 dp
│                                 │
└─────────────────────────────────┘
```

`PixelSwitch(value: state.previewValue, onChanged: (_) => state.togglePreviewValue(), onTrackStyle: state.onTrack, ...)`. 위젯 자체 클릭으로도 토글.

### 8.3 Slider preview

```
┌─ checkerboard ──────────────────┐
│                                 │
│  [─────●─────────]              │   logical 80×4, scale 6×, thumb logical 8
│   value = 0.50                  │   ← preview 보조 텍스트 (코드 emit X)
│                                 │
└─────────────────────────────────┘
```

`PixelSlider(value: state.previewValue, onChanged: state.setPreviewValue, min: state.min, max: state.max, divisions: state.divisions, ...)`. 양방향 바인딩.

---

## 9. 코드 생성

### 9.1 공통 헬퍼 (`widgets/_shared/style_codegen.dart`)

```dart
List<String> emitStyleConst(PixelShapeStyle s, String varName) {
  return [
    'const $varName = PixelShapeStyle(',
    '  corners: ${corners(s.corners)},',
    '  fillColor: ${color(s.fillColor)},',
    if (s.borderColor != null) '  borderColor: ${color(s.borderColor!)},',
    if (s.borderColor != null) '  borderWidth: ${s.borderWidth},',
    if (s.shadow != null) ...emitShadowLines(s.shadow!),
    if (s.texture != null) ...emitTextureLines(s.texture!),
    ');',
  ];
}

String color(Color c) => 'Color(0x${c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')})';

String corners(PixelCorners c) {
  // 기존 _corners() 본체 그대로 — preset identity → equality → custom symmetric.
}

List<String> emitShadowLines(PixelShadow s) { ... }
List<String> emitTextureLines(PixelTexture t) { ... }
```

### 9.2 위젯별 generator

**Box** (기존 그대로 + paired usage):
```dart
String generateBoxCode(PixelShapeStyle s, {String? labelText}) {
  final lines = emitStyleConst(s, 'style');
  if (labelText != null && labelText.isNotEmpty) {
    lines.add('');
    lines.add('// Paired usage:');
    lines.add('// PixelBox(');
    lines.add('//   logicalWidth: 32,');
    lines.add('//   logicalHeight: 16,');
    lines.add('//   style: style,');
    final escaped = labelText.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    lines.add("//   label: Text('$escaped'),");
    lines.add('// )');
  }
  return lines.join('\n');
}
```

**Switch**:
```dart
String generateSwitchCode(SwitchState state) {
  final lines = <String>[];
  lines.addAll(emitStyleConst(state.onTrack, 'onTrack'));
  lines.add('');
  lines.addAll(emitStyleConst(state.offTrack, 'offTrack'));
  lines.add('');
  lines.addAll(emitStyleConst(state.thumb, 'thumb'));
  if (state.disabledStyle != null) {
    lines.add('');
    lines.addAll(emitStyleConst(state.disabledStyle!, 'disabled'));
  }
  lines.add('');
  lines.add('PixelSwitch(');
  lines.add('  value: ${state.previewValue},');
  lines.add('  onChanged: (v) {},');
  lines.add('  onTrackStyle: onTrack,');
  lines.add('  offTrackStyle: offTrack,');
  lines.add('  thumbStyle: thumb,');
  if (state.disabledStyle != null) lines.add('  disabledStyle: disabled,');
  lines.add(');');
  return lines.join('\n');
}
```

**Slider**:
```dart
String generateSliderCode(SliderState state) {
  final lines = <String>[];
  lines.addAll(emitStyleConst(state.track, 'track'));
  lines.add('');
  lines.addAll(emitStyleConst(state.fill, 'fill'));
  lines.add('');
  lines.addAll(emitStyleConst(state.thumb, 'thumb'));
  if (state.disabledStyle != null) {
    lines.add('');
    lines.addAll(emitStyleConst(state.disabledStyle!, 'disabled'));
  }
  lines.add('');
  lines.add('PixelSlider(');
  lines.add('  value: ${state.previewValue},');
  lines.add('  onChanged: (v) {},');
  lines.add('  min: ${state.min},');
  lines.add('  max: ${state.max},');
  if (state.divisions != null) lines.add('  divisions: ${state.divisions},');
  lines.add('  trackStyle: track,');
  lines.add('  fillStyle: fill,');
  lines.add('  thumbStyle: thumb,');
  if (state.disabledStyle != null) lines.add('  disabledStyle: disabled,');
  lines.add(');');
  return lines.join('\n');
}
```

### 9.3 코드 패널 chrome — `code_view.dart`

`code_panel.dart` 의 dark `Container` + `SelectableText` + `PixelButton(COPY CODE)` 부분을 `widgets/_shared/code_view.dart` 로 이동:

```dart
class CodeView extends StatelessWidget {
  final String code;
  const CodeView({required this.code});
  // 기존 chrome 그대로, code 만 prop 으로
}
```

각 widget tuner 의 `buildCode()` = `CodeView(code: generateXxxCode(state))` (ValueListenableBuilder/AnimatedBuilder 안에서).

---

## 10. Testing 전략

### 10.1 유닛 테스트 (코드 생성기)

- `tuner/test/widgets/box/box_code_test.dart` (기존 `code_generator_test.dart` 이전)
- `tuner/test/widgets/switch/switch_code_test.dart` (신규)
  - default state → 4 const + 위젯 호출 emit
  - `disabledStyle == null` → const + 인자 둘 다 omit
  - `borderColor: null` 슬롯 → `borderColor`/`borderWidth` 라인 omit
  - shadow/texture omit-when-null
- `tuner/test/widgets/slider/slider_code_test.dart` (신규)
  - continuous (`divisions == null`) → `divisions:` omit
  - discrete → `divisions: N` emit
  - `min: 0.0, max: 1.0` 도 emit (default 값이지만 명시)

### 10.2 State 테스트

- `box_state_test.dart` (기존 패턴 그대로)
- `switch_state_test.dart`: 각 setter → 상태 변경 + `notifyListeners` 호출 확인. `togglePreviewValue` 동작.
- `slider_state_test.dart`: setMin → previewValue clamp. setDivisions(null/N) 토글.

### 10.3 Widget 테스트 (HomePage)

- `home_page_test.dart`:
  - 초기 index 0 (Box) 활성
  - NavigationRail destination 1 클릭 → Switch tuner 활성화 (`StyleSection` 위젯이 controls 영역에 보임)
  - "soon" 항목 클릭 → SnackBar 표시 (또는 `enabled: false` 시각만 확인)
  - 와이드/내로우 layout 분기: `MediaQuery` 모킹으로 `> 720` / `≤ 720` 두 케이스 — 전자는 NavigationRail 표시, 후자는 햄버거+Drawer

### 10.4 Golden 테스트 — 의도적 skip

Material chrome + 사이드바 텍스트 + 위젯별 preview 가 섞여 Linux CI 와 macOS 폰트 fallback 차이로 깨지기 쉬움 (PR #56 lesson). pixel widget 자체의 시각 회귀는 본 패키지 (`test/goldens/pixel_*/`) 가 이미 커버. tuner 시각 검증은 수동 `flutter run -d chrome` 으로 충분.

---

## 11. `tool/check_tuner_coverage.dart` 1줄 패치

현재:
```dart
const String tunerControlsDir = 'tuner/lib/src/controls';
// orphan 검출 + missing 검출 모두 이 경로 안에서만
```

→ 변경: 두 scope 분리.
```dart
const String tunerControlsDir = 'tuner/lib/src/controls';   // orphan scope (그대로)
const String tunerScanRoot    = 'tuner/lib/src';            // missing scope (recursive 확장)
```

이유: `widgets/<name>/<name>_tuner.dart` 같은 파일은 `PixelShapeStyle` 필드를 직접 grep 하지 않고 `StyleSection` 같은 wrapper 통해 간접 사용 → orphan 가짜 경고 방지를 위해 orphan scope 는 controls/ 만 유지.

위젯-fields coverage (PixelSwitch.value, PixelSlider.divisions 등) 는 본 PR 스코프 밖. 별도 follow-up issue 로 분리.

---

## 12. 새 위젯 추가 가이드 (미래 PixelButton tuner 등)

`docs/widgets/tuner_extension.md` 신설. 단계:

1. `tuner/lib/src/widgets/<name>/` 디렉토리 생성
2. `<name>_state.dart` — `ValueNotifier` 또는 `ChangeNotifier` 자체 상태
3. `<name>_controls.dart` — `StyleSection`(s) 재사용 + widget-specific 컨트롤
4. `<name>_preview.dart` — 라이브 위젯 렌더 + 체커 배경 헬퍼 재사용
5. `<name>_code.dart` — `_shared/style_codegen.dart` 재사용해서 const + 위젯 호출 emit
6. `<name>_tuner.dart` — `<Name>WidgetTuner extends WidgetTuner`, `pixelIcon` getter inline
7. `home_page.dart` 의 `_factories` 에 1줄 추가:
   ```dart
   () => <Name>WidgetTuner(),
   ```
8. `tuner/test/widgets/<name>/` 에 state + code generator + (필요 시) controls 테스트
9. `check_tuner_coverage` 자동 인식 (별 변경 없음)

---

## 13. 마이그레이션 위험 + 롤백

- `tuner/` 는 `publish_to: none` → 외부 의존성 0
- 내부 위치만 이동 (`tuner_state.dart` → `widgets/box/box_state.dart`, etc.). 함수/클래스 시그니처 변경 없음 (rename 만)
- Box behavior 가 1:1 보존되어야 — 기존 controls/ 위젯 재사용으로 시각 회귀 risk 최소
- 와이드 레이아웃 컬럼 비율 (30/70) 유지 — sidebar 80dp 가 추가되므로 controls/preview 영역이 약간 좁아짐. 의도적.
- 롤백: 이번 PR 머지 후 시각 회귀 발견되면 단일 revert 로 원복 가능 (모든 변경이 `tuner/` 안)

---

## 14. 비-목표 (이 PR 스코프 밖)

- PixelButton / PixelListTile / PixelGrid 의 실제 playground 모듈 — 추상화는 만들지만 module 자체는 별 follow-up
- pixel_ui 본 패키지 변경 — 순전히 tuner 내부
- pub.dev 배포 — 해당 사항 없음
- 위젯-fields coverage (PixelSwitch.value 등) check_tuner_coverage 검증
- Theme wire-up 코드 emit (Q4 에서 제외함 — 현재 패턴 유지)
- 다국어 (한국어 외 라벨) — 현재 영어만
- 키보드 네비게이션 (Tab/Shift+Tab) 의 사이드바 ↔ controls 이동 — Material 디폴트 동작에 의존, 추가 wiring 없음
