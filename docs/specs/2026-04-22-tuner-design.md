# pixel_ui Tuner — Web App Design

**작성일:** 2026-04-22
**저장소:** github.com/BottlePumpkin/pixel_ui
**배포 URL:** https://bottlepumpkin.github.io/pixel_ui/
**의존성:** pixel_ui (via path `../`)

## 맥락

pixel_ui v0.1.0이 pub.dev에 배포된 직후, 사용자가 `PixelShapeStyle` 값을 시각적으로 탐색하고 **생성된 Dart 코드를 복사해 쓸 수 있는 웹 기반 튜너**가 필요하다는 판단. 기존 `run_jjemi` DevMenu의 `_PixelUiTunerPage` 기능을 외부 공개 형태로 발전시킴.

목표는 "이 패키지를 설치하기 전에 감을 잡을 수 있는 인터랙티브 샌드박스". 부수적으로 **튜너 UI 자체가 pixel_ui로 만들어져 있다는 dogfooding**을 통해 패키지 정체성을 전달.

패키지 철학 계승: **본질만 먼저, 쓰임새로 진화**. 0.1 튜너는 `PixelShapeStyle` 단일 타겟에 집중하고, 사용자 피드백·실사용 경험을 바탕으로 0.2+ 확장.

배포 모델은 `rfw_gen_playground` 선례를 그대로 따름: 저장소 sibling 디렉터리 + `publish_to: none` + `flutter build web` + GitHub Pages Actions 배포.

---

## 1. 디렉터리 구조

```
pixel_ui/
├── lib/                                    (기존 — published package, 무수정)
├── example/                                (기존 — iOS+Android showcase, 무수정)
├── tuner/                                  ← 신규
│   ├── pubspec.yaml                        (name: pixel_ui_tuner, publish_to: none, pixel_ui: path ../)
│   ├── analysis_options.yaml
│   ├── lib/
│   │   ├── main.dart                       (entry + ThemeData 주입)
│   │   └── src/
│   │       ├── home_page.dart              (responsive 2-col / ≤720px stacked)
│   │       ├── tuner_state.dart            (ValueNotifier<PixelShapeStyle>)
│   │       ├── preview_panel.dart
│   │       ├── code_panel.dart
│   │       ├── code_generator.dart         (pure function: Style → Dart source)
│   │       ├── color_hex_parser.dart       (pure function: "#AABBCC" → Color?)
│   │       ├── theme.dart                  (Material ThemeData w/ pixel 팔레트)
│   │       ├── widgets/
│   │       │   ├── pixel_section_header.dart
│   │       │   └── pixel_card.dart
│   │       └── controls/
│   │           ├── corner_picker.dart
│   │           ├── color_hex_input.dart
│   │           ├── border_width_slider.dart
│   │           ├── shadow_editor.dart
│   │           └── texture_editor.dart
│   ├── test/
│   │   ├── code_generator_test.dart
│   │   └── color_hex_parser_test.dart
│   └── web/
│       ├── index.html                      (custom title/description/theme-color)
│       ├── favicon.png
│       └── manifest.json
├── .github/workflows/
│   └── deploy-tuner.yml                    ← 신규
└── README.md                               (live tuner URL 배지 추가)
```

### 구조 결정 근거

- **`tuner/` sibling of `lib/`·`example/`**: rfw_gen 패턴 일치. 기존 `example/` 모바일 쇼케이스는 스크린샷 자원으로 유지.
- **파일 분리**: `_PixelUiTunerPage` 단일 파일(376 LOC)을 컨트롤 단위로 쪼개 유지보수·테스트 용이.
- **`code_generator.dart` / `color_hex_parser.dart` 별도 파일**: 순수 함수로 분리해서 위젯 무관 단위 테스트 가능.
- **Material 의존**: 튜너는 조정 UI라 Material Form 위젯이 자연스러움. pixel_ui 본 패키지와 별개 의존.
- **`publish_to: none`**: 튜너는 pub.dev 업로드 대상 아님. 패키지 스코어에 무영향.

---

## 2. UI 레이아웃 + 상태 모델

### 2.1 반응형 레이아웃

**Width > 720px — 2-column:**
```
┌───────────────────────────────────────────────────────┐
│ ▓▓▓ PIXEL UI TUNER ▓▓▓   ← PixelBox 헤더 (full width)  │
│ Build your PixelShapeStyle, copy the code              │
├─────────────────────────────┬─────────────────────────┤
│ Controls (scrollable)       │ Preview + Code (sticky) │
│ ┌─ CORNERS ─────────────┐   │  ┌─ PREVIEW ──────┐     │
│ │ preset / custom       │   │  │  PixelBox      │    │
│ └────────────────────────┘   │  └────────────────┘     │
│ ┌─ COLORS ──────────────┐   │  ┌─ CODE ─────────┐     │
│ │ fill / border + hex   │   │  │ const style... │    │
│ └────────────────────────┘   │  └────────────────┘     │
│ ┌─ BORDER / SHADOW /    │   │  ▓▓▓ [ COPY CODE ] ▓▓▓ │
│ │   TEXTURE             │   │                          │
│ └────────────────────────┘   │                          │
└─────────────────────────────┴─────────────────────────┘
```

**Width ≤ 720px — stacked:**
```
┌───────────────────────┐
│ header                │
│ PREVIEW (sticky top)  │
│ CODE + COPY           │
│ ───── divider ─────   │
│ Controls (scrollable) │
└───────────────────────┘
```

**레이아웃 규칙**:
- `LayoutBuilder`로 `maxWidth > 720` 분기
- Controls 패널: 내부 `SingleChildScrollView`
- Preview + Code 패널: 넓은 화면에서 sticky, 좁은 화면에서 상단 고정
- 각 섹션은 `PixelCard` 프레임 안에 Material Form 컨트롤 배치

### 2.2 상태 모델

**단일 `ValueNotifier<PixelShapeStyle>` 패턴**:

```dart
// lib/src/tuner_state.dart
class TunerState extends ValueNotifier<PixelShapeStyle> {
  TunerState() : super(_initial);

  static const _initial = PixelShapeStyle(
    corners: PixelCorners.lg,
    fillColor: Color(0xFF5A8A3A),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
    shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
  );

  void setCorners(PixelCorners c) => value = value.copyWith(corners: c);
  void setFillColor(Color c) => value = value.copyWith(fillColor: c);
  void setBorderColor(Color? c) => value = value.copyWith(borderColor: c);
  void setBorderWidth(int w) => value = value.copyWith(borderWidth: w);
  void setShadow(PixelShadow? s) => value = value.copyWith(shadow: s);
  void setTexture(PixelTexture? t) => value = value.copyWith(texture: t);
}
```

**사용 패턴**: `ListenableBuilder(listenable: tunerState, builder: ...)`.

**왜 단일 ValueNotifier?** PixelShapeStyle 사본 생성은 가볍고, 프리뷰·코드 패널 양쪽이 전체 스타일을 필요로 하므로 필드별 분리가 실익 없음. 슬라이더 드래그 60fps 유지 실측으로 충분. 성능 병목 확인 시 `ChangeNotifier` 필드별 `notifyListeners()`로 refactor 가능(non-breaking).

### 2.3 코드 생성 포맷

```dart
// 예시 출력
const style = PixelShapeStyle(
  corners: PixelCorners.lg,
  fillColor: Color(0xFF5A8A3A),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
  shadow: PixelShadow(
    offset: Offset(1, 1),
    color: Color(0xFF1A3010),
  ),
);
```

**규칙**:
- 들여쓰기 2-space
- nullable 필드(`borderColor`, `shadow`, `texture`)가 null이면 해당 라인 전체 생략
- `borderColor` null이면 `borderWidth`도 같이 생략 (border 없음)
- Preset corner 감지: `PixelCorners.sharp/.xs/.sm/.md/.lg/.xl`와 동등하면 preset 이름 사용, 아니면 `.all(...)` 또는 `.only(...)`
- Color hex 표기: `Color(0xFF5A8A3A)` 대문자, 8자리 zero-padded
- Offset: `Offset(dx, dy)` 정수 변환

### 2.4 Copy 동작

```dart
onPressed: () async {
  await Clipboard.setData(ClipboardData(text: generateCode(state.value)));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied! Paste into your Dart source.')),
    );
  }
}
```

코드 블록은 `SelectableText`로도 표시해 수동 선택·복사 fallback 제공.

### 2.5 Theme (Material ThemeData with pixel 팔레트)

```dart
// lib/src/theme.dart
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

- `useMaterial3: false` → Material 2의 각진 디자인이 pixel 분위기에 더 부합
- `textTheme.fontFamily = Mulmaru` → 전체 라벨·버튼 텍스트에 픽셀 폰트 적용 (작은 크기 가독성은 Material 슬라이더·필드 자체 렌더링 품질에 의존)

---

## 3. 컨트롤별 UX 스펙

### 3.1 `corner_picker.dart`

- `SegmentedButton<String>` with 7 options: `sharp / xs / sm / md / lg / xl / custom`
- Preset 선택 시 즉시 `tunerState.setCorners(PixelCorners.lg)` 호출
- **Custom 모드 (단순화)**: single-depth 슬라이더 1개 (range `0~6`), 4개 코너 대칭 적용 (`PixelCorners.all(pattern)`)
  - depth N → pattern = `[N, N-1, ..., 1]`
  - depth 0 → empty list → `PixelCorners.sharp` 동등
- 완전 비대칭(tl≠tr≠bl≠br) 편집은 **0.2+ scope**

### 3.2 `color_hex_input.dart`

- 가로 배치: `[color swatch 20×20 PixelBox] [# AABBCC TextField]`
- 정규식: `^#?[0-9a-fA-F]{6,8}$`
- 유효 → 즉시 `setXxxColor(parsed)`, 무효 → TextField error state (빨간 border) + 상태 업데이트 중단
- Nullable 케이스(`borderColor`, `shadow.color`): TextField 왼쪽에 `enabled` 체크박스 추가. Off → `setXxx(null)`, TextField 비활성. On → 마지막 유효 값 복원 또는 기본 검정
- Swatch는 `PixelBox` 사용 (dogfooding)

### 3.3 `border_width_slider.dart`

- Material `Slider`, range `0~4`, `divisions: 4`
- `borderColor == null`일 땐 `enabled: false` (border 없으니 width 무의미)

### 3.4 `shadow_editor.dart`

- 상단에 `enabled` 체크박스 + Preset 버튼 3개: `sm (1,1) / md (2,2) / lg (4,4)`
- 하단에 수동 `dx` slider (range `-3~3`, `divisions: 6`, int) + `dy` slider 동일
- 색상 입력: `color_hex_input` 재사용
- Enabled off → `setShadow(null)`
- Preset `lg` 클릭 시 offset 4까지 설정 가능하나 슬라이더는 `-3~3` 내에서 clamp. 극단값은 preset으로만 도달

### 3.5 `texture_editor.dart`

- `enabled` 체크박스 + (enabled 시) 4개 컨트롤:
  - `density` slider: `0.0 ~ 1.0`, `divisions: 20` (0.05 단위)
  - `size` slider: `1 ~ 4` int, `divisions: 3`
  - `seed` slider: `0 ~ 100` int, `divisions: 100` + 🎲 random 버튼
  - `color`: `color_hex_input`
- Enabled off → `setTexture(null)`

### 3.6 `preview_panel.dart`

- 체커보드 배경 + 중앙에 실제 `PixelBox`
- 고정값: `logicalWidth: 80`, `logicalHeight: 24`, render `width: 320` (4x)
- 크기 조정 컨트롤 (1x/2x/4x 토글)은 **0.2+ scope**

### 3.7 `code_panel.dart`

- `SelectableText` 안에 `generateCode(style)` 결과 표시
- Monospace 폰트(`Courier`, `ui-monospace`, 시스템 mono)
- 하단에 `PixelButton` "COPY CODE" — normal/pressed 스타일 페어
- 클릭 시 `Clipboard.setData` + SnackBar 피드백
- 클립보드 권한 문제 시 (Safari) try/catch 후 "수동 선택 + Cmd+C" 안내 SnackBar

### 3.8 `pixel_section_header.dart`

```dart
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
            width: 4, height: 20,
            child: ColoredBox(color: Color(0xFF5A8A3A)),
          ),
          const SizedBox(width: 8),
          Text(title, style: PixelText.mulmaru(fontSize: 18)),
        ],
      ),
    );
  }
}
```

### 3.9 `pixel_card.dart`

```dart
class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const PixelCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: padding,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A2A), width: 2),
        ),
      ),
      child: child,
    );
  }
}
```

**주**: `PixelBox`는 logical 비율 고정이라 가변 콘텐츠 카드에 부적합. 각진 Material `Container`로 대체. 0.2+에서 본 패키지에 `PixelContainer` 신규 추가 시 교체 후보.

---

## 4. 배포 워크플로우

### 4.1 `.github/workflows/deploy-tuner.yml`

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

### 4.2 주요 결정

- **Flutter `3.32.7` 고정**: pixel_ui `environment.flutter: '>=3.32.0'` 최소와 일치
- **`--base-href /pixel_ui/`**: GitHub Pages 서브패스 URL 대응
- **`--release`**: tree-shake 활성화, 번들 크기 최소화
- **Analyze 단계 배포 게이트**: analyze 실패 시 배포 중단
- **Path filter 트리거**: `tuner/**`, `lib/**`, `pubspec.yaml`, `assets/**`, workflow 자체 변경 시. 문서·README 수정엔 빌드 안 돎
- **`workflow_dispatch`**: 수동 재배포 가능 (UI 변경 없이 설정만 바꿨을 때 등)

### 4.3 첫 배포 전 수동 설정 (사용자 1회)

1. `https://github.com/BottlePumpkin/pixel_ui/settings/pages` 접속
2. **Source** 드롭다운 → **"GitHub Actions"** 선택
3. Save

이후 push만으로 자동 배포.

### 4.4 배포 후 검증 체크리스트

- [ ] https://bottlepumpkin.github.io/pixel_ui/ 페이지 로드
- [ ] 타이틀 "pixel_ui — PixelShapeStyle Tuner"
- [ ] Mulmaru 폰트 정상 렌더링
- [ ] Corner preset 변경 시 프리뷰·코드 즉시 반영
- [ ] hex 입력 잘못된 형식 → error state
- [ ] shadow enabled toggle off → 코드에서 `shadow:` 라인 사라짐
- [ ] Copy 버튼 → 클립보드 복사 + SnackBar
- [ ] 모바일 뷰포트(chrome devtools responsive mode)에서 stacked 레이아웃
- [ ] DevTools Console 에러 없음

### 4.5 README 업데이트

```markdown
# pixel_ui

[![pub package](https://img.shields.io/pub/v/pixel_ui.svg)](https://pub.dev/packages/pixel_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Live Tuner](https://img.shields.io/badge/Live-Tuner-5A8A3A.svg)](https://bottlepumpkin.github.io/pixel_ui/)

Pixel-art design system for Flutter — parametric shapes, interactive buttons, and a bundled pixel font.

**🎨 [Try the PixelShapeStyle tuner →](https://bottlepumpkin.github.io/pixel_ui/)**

...
```

### 4.6 `web/index.html` 커스터마이징

Flutter `create` 기본값에서 다음을 명시적으로 변경:
- `<title>pixel_ui — PixelShapeStyle Tuner</title>`
- `<meta name="description" content="Interactive tuner for pixel_ui — build a PixelShapeStyle visually and copy the generated Dart code.">`
- `<meta name="theme-color" content="#F5F1E8">`
- (선택) Open Graph 메타 — 0.2+

---

## 5. 테스트·마일스톤·리스크

### 5.1 테스트 범위

**`tuner/test/code_generator_test.dart` (필수)**:
- preset corner → `corners: PixelCorners.lg,`
- custom corner → `corners: PixelCorners.all([3, 2, 1]),`
- borderColor null → `borderColor`·`borderWidth` 라인 모두 생략
- shadow null → shadow 라인 생략
- texture 있음 → multi-line 블록 포함
- fillColor `0xFF5A8A3A` → 정확한 대문자·패딩 표기

**`tuner/test/color_hex_parser_test.dart` (필수)**:
- 유효: `"#AABBCC"`, `"aabbcc"`, `"FFAABBCC"` (ARGB)
- 무효: `"XYZ"`, `"12"`, `""` → null 반환

**의도적 미포함 (0.2+)**: 위젯 상호작용 테스트, 골든 테스트.

**커버리지 목표**: 순수 로직 함수 90%+, 위젯 측정 X.

### 5.2 마일스톤

- **M1 — Scaffold + State + Preview**: `tuner/` dir, `flutter create`, `TunerState`, 2-column desktop layout, PixelBox live render. 로컬 `flutter run -d chrome` 확인.
- **M2 — Controls**: 5개 control 구현, TunerState 반영, 단위 테스트.
- **M3 — Code generation + Copy + Responsive**: `generateCode` + 스냅샷 테스트, PixelButton Copy + 클립보드 + SnackBar, ≤720px stacked, 공용 위젯(`PixelSectionHeader`/`PixelCard`).
- **M4 — Deploy**: workflow, `web/index.html`, README, 사용자 Pages 설정, 첫 배포 + 검증.

### 5.3 리스크

| 리스크 | 확률 | 영향 | 완화 |
|---|---|---|---|
| Mulmaru 번들 웹 반영 실패 | 낮음 | 폰트 안 뜸 | M1에서 로컬 chrome 즉시 확인 |
| 클립보드 API Safari 권한 | 중간 | Copy 실패 | try/catch + fallback 안내 |
| base-href 미적용 | 중간 | 404 | workflow `--base-href /pixel_ui/` 고정 |
| 빌드 크기 ~2MB+ | 확실 | 첫 로드 느림 | 0.1 수용, 0.2+ renderer 검토 |
| Pages 설정 누락 | 중간 | 첫 배포 실패 | M4 체크리스트 명시 |
| CJK 폰트 초기 FOUT | 중간 | 깜빡임 | M4에서 `<link rel="preload" as="font">` 추가 검토 |

### 5.4 성공 기준 (Done 정의)

M4 끝난 시점 다음 모두 true:
- [ ] 배포 URL 접속 시 tuner 화면 + Mulmaru 정상 렌더
- [ ] 모든 컨트롤이 프리뷰·코드에 즉시 반영
- [ ] hex 오타 error state, 정상 입력 반영
- [ ] Nullable toggle (shadow/texture/borderColor) on/off 동작
- [ ] Copy 버튼 → 클립보드 성공 + SnackBar
- [ ] 모바일 stacked 레이아웃 깨짐 없음
- [ ] `flutter analyze`/`flutter test` 모두 통과
- [ ] DevTools Console 에러 없음

### 5.5 0.2+ 향후 확장 (ROADMAP 연계, 현재 scope 외)

- Custom corner per-side (비대칭)
- Dark theme toggle
- Preview zoom 1x/2x/4x/8x
- PixelButton 튜너 탭
- URL 파라미터 스타일 인코딩/공유
- 커뮤니티 프리셋 갤러리
- 튜너 UI 전면 픽셀화 (Material Slider → PixelSlider → 본 패키지 승격)

---

## 6. 확정된 결정 요약

| 항목 | 결정 |
|---|---|
| 스코프 | Tuner 전용 웹 앱 (preview/docs 미포함) |
| pixel_ui 의존성 | path (`../`) |
| Tuner 기능 타겟 | PixelShapeStyle 단일 + Dart 코드 복사 |
| UI 스타일 | B — 프레이밍·CTA pixel_ui, 폼 컨트롤 Material + pixel 팔레트. 0.2+에서 전면 픽셀화 경로 |
| 상태 관리 | 단일 `ValueNotifier<PixelShapeStyle>` + copyWith |
| 레이아웃 | > 720px 2-column, ≤ 720px stacked |
| 다크 모드 | 0.2+ 연기 |
| 코드 생성 | preset 감지 + nullable 필드 생략 + `Color(0xFFAABBCC)` 포맷 |
| Copy 동작 | `Clipboard.setData` + SnackBar + SelectableText fallback |
| 배포 URL | https://bottlepumpkin.github.io/pixel_ui/ |
| Flutter 버전 | 3.32.7 고정 |
| CI 트리거 | path filter: `tuner/** lib/** pubspec.yaml assets/**` + `workflow_dispatch` |
| Pages Source | GitHub Actions (사용자 1회 수동 설정) |
| 테스트 | 순수 로직 함수 단위 테스트만 (`code_generator`, `color_hex_parser`) |
| 마일스톤 | M1 scaffold → M2 controls → M3 code+copy+responsive → M4 deploy |

---

## 다음 단계

이 스펙을 기반으로 `superpowers:writing-plans` 스킬로 실행 계획(`tuner-implementation-plan.md`)을 작성. M1~M4 마일스톤별로 태스크를 분할하고 각 태스크에 exact 코드 + 테스트 + 검증 커맨드를 포함.
