# pixel_ui Roadmap

작업 위치: `/Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui`
공개 URL: https://pub.dev/packages/pixel_ui · https://github.com/BottlePumpkin/pixel_ui
배포 계정: `p4569zz@gmail.com` (Google OAuth, pub.dev uploader)

0.1.0에서 의도적으로 scope를 좁힌 항목들을 향후 버전에서 단계적으로 확장한다. 철학: **본질만 먼저, 쓰임새로 진화**. 사용자 피드백·실사용 경험 없이는 기능을 미리 추가하지 않는다.

---

## 🎯 0.1.1 — 가장 가까운 다음 배포

### A. 스크린샷 4장 캡처 + pubspec 복원

**목적**: pub.dev 리스팅에 썸네일·쇼케이스 노출. 스코어 +5점 가량.

**작업 순서**:

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui/example
fvm flutter run -d "iPhone 15 Pro"    # 또는 부팅된 다른 시뮬레이터
```

앱 실행 후 4장 수동 캡처 (시뮬레이터 `Cmd+S` 또는 `xcrun simctl io booted screenshot <path>`):

| 파일 | 대상 섹션 |
|---|---|
| `example/assets/screenshots/1.png` | 최상단 "PIXEL UI / PRIMITIVES + FONT" 히어로 카드 |
| `example/assets/screenshots/2.png` | Section 3 — TAP ME + DISABLED 버튼 |
| `example/assets/screenshots/3.png` | Section 1 — sharp → xl 코너 스케일 wrap |
| `example/assets/screenshots/4.png` | Section 4 — plain vs textured 박스 |

`pubspec.yaml` screenshots 섹션 복원 (0.1.0에서 삭제했던 블록):

```yaml
topics:
  - widgets
  - design-system
  - pixel-art
  - retro
  - game-ui

screenshots:
  - description: 'Complete pixel UI composed from primitives'
    path: example/assets/screenshots/1.png
  - description: 'Interactive pixel button with press state'
    path: example/assets/screenshots/2.png
  - description: 'Parametric corner scale from sharp to xl'
    path: example/assets/screenshots/3.png
  - description: 'Plain vs textured surfaces via PixelTexture'
    path: example/assets/screenshots/4.png

environment:
```

`pubspec.yaml`: `version: 0.1.0` → `version: 0.1.1`.

`CHANGELOG.md` 맨 위에 추가:

```markdown
## 0.1.1 — YYYY-MM-DD

- Add pub.dev listing screenshots (hero composition, buttons, corners, texture).
```

배포 (공통 리듬 참조):

```bash
cd /Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui
fvm flutter analyze && fvm flutter test
fvm dart pub publish --dry-run   # 0 warnings 확인
fvm dart pub publish --force     # 배포
git tag -a v0.1.1 -m "v0.1.1 — pub.dev screenshots"
git push origin main v0.1.1
```

### B. README 배지 동작 확인

현재 README 상단:
```markdown
[![pub package](https://img.shields.io/pub/v/pixel_ui.svg)](https://pub.dev/packages/pixel_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

배포 후 버전 배지가 `0.1.1`로 갱신되는지 확인. 안 되면 쿼리(`?cacheSeconds=60`)로 shields.io 캐시 우회.

---

## 🎯 0.2.0 — 중기 로드맵

### C. CI 워크플로우 추가

**파일**: `.github/workflows/ci.yml` (신규)

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.7'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: dart pub publish --dry-run

  example:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.7'
      - run: flutter pub get
        working-directory: example
      - run: flutter analyze
        working-directory: example
```

PR/push 시 analyze + test + dry-run 자동 검증 → 이후 모든 배포의 안전망.

### D. Mulmaru Mono 번들 추가

**이유**: 0.1.0에서 Proportional만 번들했음. 코드·터미널 UI 용도로 Mono 필요 시 제공.

**작업 순서**:

1. 업스트림 다운로드:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/mushsooni/mulmaru/main/MulmaruMono.ttf \
     -o assets/fonts/MulmaruMono.ttf
   shasum -a 256 assets/fonts/MulmaruMono.ttf
   # CHANGELOG에 SHA 기록
   ```

2. `pubspec.yaml` fonts 섹션 확장:
   ```yaml
   flutter:
     fonts:
       - family: Mulmaru
         fonts:
           - asset: assets/fonts/Mulmaru.ttf
       - family: MulmaruMono
         fonts:
           - asset: assets/fonts/MulmaruMono.ttf
   ```

3. `lib/src/pixel_text.dart` 확장 (minor bump, non-breaking):
   ```dart
   static const String mulmaruMonoFontFamily = 'MulmaruMono';

   static TextStyle mulmaruMono({
     double fontSize = 16,
     Color color = const Color(0xFF000000),
     Color? shadowColor,
     Offset shadowOffset = const Offset(1, 1),
     double height = 1.0,
     FontWeight? fontWeight,
     double? letterSpacing,
     List<Shadow>? shadows,
   }) {
     final resolvedShadows = shadows ??
         (shadowColor != null
             ? <Shadow>[Shadow(offset: shadowOffset, color: shadowColor)]
             : null);
     return TextStyle(
       fontFamily: mulmaruMonoFontFamily,
       package: mulmaruPackage,
       fontSize: fontSize,
       color: color,
       height: height,
       fontWeight: fontWeight,
       letterSpacing: letterSpacing,
       shadows: resolvedShadows,
     );
   }
   ```

4. 테스트 추가 (`test/pixel_text_test.dart`):
   ```dart
   test('mulmaruMono() returns TextStyle with MulmaruMono font', () {
     final style = PixelText.mulmaruMono(fontSize: 16);
     expect(style.fontFamily, 'MulmaruMono');
     expect(style.height, 1.0);
   });
   ```

5. README "Typography" 섹션에 Mono 사용 예시 추가.

6. CHANGELOG + 버전 bump + publish (공통 리듬).

### E. 골든 테스트 도입 (`PixelShapePainter` 픽셀 정확도)

**왜 지금**: 0.1.0에서 "example 앱 시각 검증으로 대체"해 연기했으나, API 안정화 후 회귀 방지 가치 상승.

**작업 순서**:

1. `test/goldens/` 디렉터리 생성.

2. `test/pixel_shape_painter_golden_test.dart`:
   ```dart
   import 'package:flutter/widgets.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:pixel_ui/pixel_ui.dart';

   void main() {
     testWidgets('PixelBox md corners no shadow matches golden', (tester) async {
       await tester.pumpWidget(const Directionality(
         textDirection: TextDirection.ltr,
         child: Center(child: PixelBox(
           logicalWidth: 16, logicalHeight: 16,
           style: PixelShapeStyle(
             corners: PixelCorners.md,
             fillColor: Color(0xFF00FF00),
             borderColor: Color(0xFF003300),
             borderWidth: 1,
           ),
         )),
       ));
       await expectLater(
         find.byType(PixelBox),
         matchesGoldenFile('goldens/box_md_plain.png'),
       );
     });
     // 추가 케이스: with shadow (positive/negative offset), with texture,
     // asymmetric corners (topTab/bottomTab 조합)
   }
   ```

3. 최초 실행 시 `fvm flutter test --update-goldens`로 baseline 생성 후 커밋.

4. CI test 스텝에 골든 실행 포함. 주의: Flutter의 골든은 OS/렌더러 편차가 있어 CI runner OS를 고정해야 안정적. 픽셀 아트는 `isAntiAlias=false`라 편차 적음.

### F. 스크린샷 자동화 (integration_test)

**왜**: 매 릴리스마다 수동 캡처 부담 제거.

**작업 순서**:

1. `example/integration_test/screenshots_test.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:integration_test/integration_test.dart';
   import 'package:pixel_ui_example/main.dart';

   void main() {
     final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

     testWidgets('capture showcase screenshots', (tester) async {
       await tester.pumpWidget(const PixelUiShowcaseApp());
       await tester.pumpAndSettle();

       await binding.convertFlutterSurfaceToImage();
       await binding.takeScreenshot('1');

       await tester.scrollUntilVisible(find.text('TAP ME'), 100);
       await binding.takeScreenshot('2');

       await tester.scrollUntilVisible(find.text('1. Corners scale'), -400);
       await binding.takeScreenshot('3');

       await tester.scrollUntilVisible(find.text('4. Texture'), 400);
       await binding.takeScreenshot('4');
     });
   }
   ```

2. `example/pubspec.yaml` `dev_dependencies:`에 `integration_test: { sdk: flutter }` 추가.

3. 실행:
   ```bash
   cd example
   fvm flutter drive --driver=integration_test/driver.dart \
                     --target=integration_test/screenshots_test.dart \
                     -d "iPhone 15 Pro"
   ```

4. CI macOS runner + 시뮬레이터 설정 필요 — 비용·복잡도 고려해 초기엔 수동 릴리스 유지 후 주기 정착 시 도입.

---

## 🎯 1.0.0 — 장기 로드맵

### G. 플랫폼 지원 확장 (Web / macOS / Linux / Windows)

**효과**: pub.dev Platform 스코어 10 → 20 만점.

**작업 순서**:

1. example scaffold 재생성:
   ```bash
   cd example
   fvm flutter create --platforms=ios,android,web,macos,linux,windows .
   ```

2. 각 플랫폼 빌드 검증:
   ```bash
   fvm flutter build web
   fvm flutter build macos
   # ...
   ```

3. lib 코드 자체는 `flutter/widgets`·`flutter/rendering`만 사용하므로 플랫폼 특화 의존성 없음 (`Canvas` API 전 플랫폼 공통). 그래도 Web(CanvasKit)·macOS에서 픽셀 정렬 깨지는지 실기 확인 필수.

4. CI multi-platform build matrix 추가.

### H. API 안정 선언 (1.0.0 semver 약속)

0.x 동안 쌓인 사용자 피드백 반영해 breaking change 소화 → 1.0.0 bump. 이후 API 변경은 major bump 필요.

---

## 🛠 공통 배포 리듬 (모든 버전 공통)

```text
1. 브랜치 or 커밋 단위로 작업 (개인 repo면 main 직접 커밋도 OK)
2. 코드 변경 → 테스트 추가/업데이트 (TDD)
3. fvm flutter analyze
4. fvm flutter test
5. pubspec.yaml version bump + CHANGELOG entry 추가 (맨 위)
6. fvm dart pub publish --dry-run    # 0 warnings 확인
7. 배포 계정 재확인:
   cat ~/Library/Application\ Support/dart/pub-credentials.json | grep -i email
   # idToken JWT payload의 email 필드가 p4569zz@gmail.com인지 확인
8. fvm dart pub publish              # 또는 --force (대화형 y 스킵)
9. git tag -a vX.Y.Z -m "vX.Y.Z — summary"
10. git push origin main vX.Y.Z
11. https://pub.dev/packages/pixel_ui 방문, 새 버전·스크린샷·토픽·README 렌더링 확인
```

---

## ⚠️ 잠재 함정

- **Hot restart ≠ 패키지 재해석**: 워크스페이스 ↔ pub.dev 의존성 스위치 후에는 **cold `flutter run`** 필요. 하지 않으면 "Member not found" 발생 (`.dart_tool/flutter_build/<hash>/` 캐시가 옛 경로를 잡음). 애매하면 `fvm flutter clean && melos bs && flutter run`.
- **pub.dev retract 30일 한정**: 버전 올리고 바로 치명적 버그 발견 시 30일 이내엔 `dart pub retract X.Y.Z`로 신규 설치 차단 가능, 이후엔 deprecate만. 치명적 이슈면 즉시 hotfix(`X.Y.Z+1`) 배포가 더 안전.
- **퍼블리셔 계정 잘못 로그인**: 첫 배포 때만 중요하다고 방심하지 말 것. 새 기능/테스트 배포 시에도 **jobis.co로 로그인된 상태에서 publish 금지**. 매번 credentials 확인 리듬에 포함.
- **OFL 호환 유지**: `assets/fonts/Mulmaru.ttf`를 절대 재인코딩·최적화하지 말 것 (OFL Reserved Font Name + copyright 메타데이터 훼손 위험). `OFL.txt` 파일도 동반 배포 유지 필수.
- **shields.io 캐시**: README 배지는 ~5분 캐시. 배포 직후 버전 배지가 갱신 안 보여도 대기 후 새로고침.

---

## 우선순위 제안

1. **A (스크린샷 0.1.1)** — 즉시 가치 최대
2. **C (CI)** — 이후 모든 배포의 안전망
3. **D (Mulmaru Mono)** — 요청 또는 본인이 쓸 일 생기면
4. **E (골든 테스트)** — 회귀 방지, CI 갖춘 뒤
5. **F (스크린샷 자동화)** — 릴리스 주기 확립 후
6. **G (플랫폼 확장)** — 1.0 직전 마지막 준비

---

## 관련 문서

- 초기 배포 설계 (모노레포 내): `3o3_flutter/docs/superpowers/specs/2026-04-22-pixel-ui-publish-design.md`
- 초기 배포 실행 계획 (모노레포 내): `3o3_flutter/docs/superpowers/plans/2026-04-22-pixel-ui-publish.md`
