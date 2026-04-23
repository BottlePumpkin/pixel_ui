# pixel_ui Roadmap

작업 위치: `/Users/byeonghopark-jobis/dev/byeonghopark/pixel_ui`
공개 URL: https://pub.dev/packages/pixel_ui · https://github.com/BottlePumpkin/pixel_ui
배포 계정: `p4569zz@gmail.com` (Google OAuth, pub.dev uploader)

0.1.0에서 의도적으로 scope를 좁힌 항목들을 향후 버전에서 단계적으로 확장한다. 철학: **본질만 먼저, 쓰임새로 진화**. 사용자 피드백·실사용 경험 없이는 기능을 미리 추가하지 않는다.

---

## ✅ 0.1.1 — 완료 (2026-04-22)

- pub.dev 리스팅에 스크린샷 5장 추가 (hero · corners · shadows · buttons · texture)
- README `## Gallery` 섹션 + `doc/screenshots/` 자산 추가
- `tool/update_screenshots.sh`로 골든 기반 재생성 자동화

배포는 `CHANGELOG.md`의 0.1.1 엔트리 참조.

---

## 🎯 0.2.0 — 중기 로드맵

### ✅ C. CI 워크플로우 — 완료

- PR #1: `.github/workflows/test.yml` (analyze + test + `dart pub publish --dry-run` on push/PR)
- PR #1: `PixelShapePainter` 골든 테스트 스위트 (`test/pixel_shape_painter_golden_test.dart`)
- Platform build matrix: `.github/workflows/build.yml` (6 OS/target 조합)
- PR #2: `.github/workflows/publish.yml` (태그 push 시 OIDC 자동 배포 + GitHub Release)

이후 모든 배포는 publish.yml 태그 트리거로 진행.

### ✅ D. Mulmaru Mono 번들 — 완료 (0.2.1, 2026-04-23)

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

### ✅ E. 골든 테스트 — 완료

- PR #1 (`9dde14e`): `test/shape_painter_golden_test.dart` 하네스 + 12 케이스 baseline (CI Ubuntu runner 고정)
- PR #6 (`48e8c6f`): 11 케이스 확장 → 총 23 케이스
- 커버리지: corners(sharp/xs/sm/md/lg/xl), shadow(sm/md/lg/negative/asymmetric/sharp+shadow/shadow+texture), texture(off/on/dense/size2), border(borderless/thick), 비대칭 corners(top tab/bottom tab/tl-only/top+bottom)
- `test.yml`에서 매 PR/push마다 실행 (`--exclude-tags screenshot`)

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

`.github/workflows/publish.yml`이 태그 push를 감지해 자동 배포한다. 요약:

```text
1. 코드 변경 + 테스트
2. pubspec.yaml version bump + CHANGELOG.md 엔트리
3. git commit → git tag -a vX.Y.Z → git push origin main vX.Y.Z
4. Actions 탭에서 성공 확인 → pub.dev 렌더링 확인
```

자동으로 실행되는 게이트·세부 절차·OIDC 구성은 `CLAUDE.md`의 "배포 리듬" 섹션 참조.

---

## ⚠️ 잠재 함정

- **Hot restart ≠ 패키지 재해석**: 워크스페이스 ↔ pub.dev 의존성 스위치 후에는 **cold `flutter run`** 필요. 하지 않으면 "Member not found" 발생 (`.dart_tool/flutter_build/<hash>/` 캐시가 옛 경로를 잡음). 애매하면 `fvm flutter clean && melos bs && flutter run`.
- **pub.dev retract 30일 한정**: 버전 올리고 바로 치명적 버그 발견 시 30일 이내엔 `dart pub retract X.Y.Z`로 신규 설치 차단 가능, 이후엔 deprecate만. 치명적 이슈면 즉시 hotfix(`X.Y.Z+1`) 배포가 더 안전.
- **퍼블리셔 계정 잘못 로그인**: 첫 배포 때만 중요하다고 방심하지 말 것. 새 기능/테스트 배포 시에도 **jobis.co로 로그인된 상태에서 publish 금지**. 매번 credentials 확인 리듬에 포함.
- **OFL 호환 유지**: `assets/fonts/Mulmaru.ttf`를 절대 재인코딩·최적화하지 말 것 (OFL Reserved Font Name + copyright 메타데이터 훼손 위험). `OFL.txt` 파일도 동반 배포 유지 필수.
- **shields.io 캐시**: README 배지는 ~5분 캐시. 배포 직후 버전 배지가 갱신 안 보여도 대기 후 새로고침.

---

## 우선순위 제안

1. ~~A (스크린샷 0.1.1)~~ — 완료
2. ~~C (CI)~~ — 완료 (test.yml + publish.yml + build.yml)
3. ~~D (Mulmaru Mono)~~ — 완료 (0.2.1)
4. ~~E (골든 테스트)~~ — 완료 (PR #1 + #6, 23 케이스)
5. **F (스크린샷 자동화)** — 릴리스 주기 확립 후
6. G (플랫폼 확장) — 1.0 직전 마지막 준비

---

## 관련 문서

- 초기 배포 설계 (모노레포 내): `3o3_flutter/docs/superpowers/specs/2026-04-22-pixel-ui-publish-design.md`
- 초기 배포 실행 계획 (모노레포 내): `3o3_flutter/docs/superpowers/plans/2026-04-22-pixel-ui-publish.md`
