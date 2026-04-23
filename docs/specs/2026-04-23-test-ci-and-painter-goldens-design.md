# Test CI Job + PixelShapePainter Unit Goldens — Design

**날짜**: 2026-04-23
**대상 버전**: 0.2.1 (CI/test infra 변경, 패키지 코드 변경 없음 → 패키지 배포 불필요)
**목적**: 모든 PR/push에 대해 패키지 자체 검증(analyze + test + dry-run)을 자동화하고, `PixelShapePainter`의 픽셀 단위 회귀를 골든 테스트로 잡는다.

---

## 1. 배경

0.2.0에서 플랫폼 확장과 함께 `.github/workflows/build.yml`(6 OS/타깃 빌드 매트릭스)이 추가됐다. 그러나:

- 현재 CI는 **example 앱이 빌드되는지**만 검증한다. 패키지 자체의 `flutter analyze`·`flutter test`·`dart pub publish --dry-run`은 어떤 잡에서도 실행되지 않는다.
- 단위/위젯 테스트가 깨져도 PR이 통과한다.
- 회귀 진단을 좁힐 수 있는 골든은 `test/screenshots/scenes/`(쇼케이스 합성 컷, pub.dev 스크린샷용)뿐이다. 합성 컷이 깨지면 어떤 코너/그림자/텍스처 조합이 회귀했는지 위치 특정이 어렵다.

이 두 갭을 한 사이클에 메운다.

---

## 2. Goals / Non-goals

### Goals
- 모든 PR/push에서 패키지 자체 검증이 자동 실행된다.
- example 앱 lint 회귀도 PR에서 잡힌다.
- `PixelShapePainter`의 코너 프리셋·그림자·텍스처·비대칭 조합 회귀가 단위 골든으로 잡힌다.
- 골든 baseline은 CI runner(Linux)에서 생성된 것을 진실로 삼고, 로컬 macOS는 best-effort로 운용한다.

### Non-goals
- `dart format` 강제 — 별도 사이클에서 일괄 포맷 후 도입.
- Dart SDK 캐시(`actions/cache`) — 현재 빌드 시간이 문제 되지 않음.
- 30+개 케이스의 광범위한 골든 매트릭스 — YAGNI, 회귀 발생 시 점진 추가.
- 패키지 코드 변경 → 0.2.1 pub.dev 배포 불필요 (CI/test infra 변경만).

---

## 3. A1 — `test.yml` CI 잡 신규

### 3.1 형태 결정

기존 `build.yml`에 잡 추가가 아닌 **별도 `.github/workflows/test.yml` 신규**.

**근거**:
- **실행 시간 격차**: test 잡 ~1분 (Ubuntu 1대), build 매트릭스 ~5–10분. 분리 시 PR에서 test 결과를 빠르게 확인.
- **책임 분리**: test = 패키지 자체 검증, build = 다운스트림 example 앱이 모든 플랫폼에서 빌드되는지. 실패 시 진단 경로가 다름.
- **배지 분리 가능**: README에 test/build 배지를 따로 달아 신호 명확화.

### 3.2 워크플로우 구성

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

### 3.3 단계별 의도

| 단계 | 잡힘 | 비고 |
|---|---|---|
| Pub get (root) | dependency resolution 실패 | `pubspec.yaml` 의존성 손상 신호 |
| Analyze (package) | lint·타입 회귀 | `analysis_options.yaml` 위반 |
| Test (package) | 단위/위젯/골든 회귀 | A2의 단위 골든도 여기서 실행됨 |
| Publish dry-run | 패키지 형식 위반 | 0 warnings 유지가 배포 게이트 |
| Pub get (example) | example 의존성 회귀 | path dependency 깨짐 신호 |
| Analyze (example) | example lint 회귀 | 살아있는 다운스트림 코드의 회귀 |

### 3.4 README 배지

```markdown
[![Test](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml)
[![Build](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml)
```

기존 build 배지 옆에 test 배지를 추가한다.

---

## 4. A2 — `PixelShapePainter` 단위 골든

### 4.1 파일 위치

- 테스트 파일: `test/shape_painter_golden_test.dart` (신규, 단일 파일)
- 골든 디렉터리: `test/goldens/painter/*.png` (신규)

기존 `test/screenshots/scenes/`(쇼케이스 합성 + pub.dev 스크린샷용)와는 **물리적으로 분리**한다. 두 디렉터리의 목적이 다름:
- `test/screenshots/scenes/` = 마케팅 산출물, "어떻게 보이는가" 강조
- `test/goldens/painter/` = 회귀 진단, "이 케이스가 깨졌는가" 강조

### 4.2 매트릭스 (12개, 최소 구성)

YAGNI. 회귀의 대부분은 아래 기본 조합에서 발생. 부족하면 회귀 발생 시 해당 케이스를 추가한다.

| # | 카테고리 | 케이스 | 파일명 |
|---|---|---|---|
| 1 | corners | sharp | `corners_sharp.png` |
| 2 | corners | xs | `corners_xs.png` |
| 3 | corners | sm | `corners_sm.png` |
| 4 | corners | md | `corners_md.png` |
| 5 | corners | lg | `corners_lg.png` |
| 6 | corners | xl | `corners_xl.png` |
| 7 | shadow | sm + md corners | `shadow_sm.png` |
| 8 | shadow | md + md corners | `shadow_md.png` |
| 9 | shadow | lg + md corners | `shadow_lg.png` |
| 10 | texture | on (md corners) | `texture_on.png` |
| 11 | texture | off (md corners) | `texture_off.png` |
| 12 | asymmetric | topTab + bottomTab | `asymmetric_tabs.png` |

**제외 (의도적)**:
- 음수 offset 그림자 (회귀 발생 시 추가)
- borderColor null vs set 차이 (회귀 발생 시 추가)
- 코너×그림자×텍스처 곱집합 (조합 폭발, YAGNI)

### 4.3 logical 크기

모든 케이스 **16×16 logical pixels 고정**.

**근거**:
- 픽셀 아트의 본질이 작은 단위.
- 골든 PNG가 작아짐 (~수백 바이트), git diff에서 시각적으로 검토 가능.
- 가변 크기는 "왜 이 케이스만 크기가 다른가" 의문을 만들어 의도가 흐려짐.

### 4.4 OS 편차 처리

Flutter 골든은 OS/렌더러 편차가 알려진 함정. 픽셀 아트는 `isAntiAlias=false`라 편차가 작지만 0이 아님.

**전략**:
- baseline 생성: **ubuntu-latest** (CI runner와 동일)에서 `flutter test --update-goldens --tags golden`
- 진실의 출처: **CI**. CI에서 통과해야 머지.
- 로컬 macOS: best-effort. 깨지면 "CI에서 통과하는지" 확인하고 진행.
- 평소 `flutter test`는 골든 제외해 빠르게: `--exclude-tags golden` 또는 `--tags golden`로 분리.

**구현**: 테스트 파일 상단에 `@Tags(['golden'])` 어노테이션 추가.

### 4.5 테스트 파일 골격

```dart
@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  group('PixelShapePainter goldens', () {
    Future<void> pumpBox(WidgetTester tester, PixelShapeStyle style) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 16,
            logicalHeight: 16,
            style: style,
          ),
        ),
      ));
    }

    testWidgets('corners sharp', (tester) async {
      await pumpBox(tester, const PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFF00FF00),
        borderColor: Color(0xFF003300),
        borderWidth: 1,
      ));
      await expectLater(
        find.byType(PixelBox),
        matchesGoldenFile('goldens/painter/corners_sharp.png'),
      );
    });

    // ... 11개 케이스 동일 패턴
  });
}
```

### 4.6 CI 통합

A1의 `test.yml`이 `flutter test`를 실행할 때 골든 테스트가 자동 포함된다 (`@Tags(['golden'])`는 `--exclude-tags`로 제외하지 않는 한 실행됨). CI 잡에 추가 단계 불필요.

평소 로컬 개발에서 빠른 피드백을 원하면:
```bash
fvm flutter test --exclude-tags golden  # 골든 제외 빠른 실행
fvm flutter test --tags golden           # 골든만
fvm flutter test --tags golden --update-goldens  # baseline 갱신 (CI Linux와 다를 수 있음 주의)
```

---

## 5. 위험 / 미해결

### 위험 1: 로컬 macOS에서 골든 깨짐
- **완화**: 명시적으로 "CI가 진실" 규칙. README/CONTRIBUTING에 한 줄 명시.
- **만약 너무 자주 깨지면**: macOS용 별도 골든 디렉터리 (`test/goldens/painter/macos/`) 도입 — 현재는 YAGNI로 보류.

### 위험 2: Flutter 버전 업그레이드 시 일괄 깨짐
- **완화**: Flutter SDK 픽셀 렌더링 변경은 드물지만 발생 가능. 깨지면 baseline 일괄 갱신 + diff 시각 검토.
- **CI Flutter 버전 고정**: `'3.32.7'`. 업그레이드는 별도 PR에서 다룸.

### 위험 3: baseline 생성을 macOS 로컬에서 실수로 하고 커밋
- **완화**: PR 리뷰에서 발견. CI가 깨지면 곧바로 드러남. baseline 갱신은 항상 CI 잡 결과에서 산출하거나, 로컬 갱신 후 CI 결과로 검증.

---

## 6. 구현 순서

1. **A1 먼저** — `.github/workflows/test.yml` 신규 + README 배지 추가. 머지 → 다음 PR부터 테스트 잡 활성.
2. **A2** — `test/shape_painter_golden_test.dart` 작성 + `test/goldens/painter/` baseline 생성. CI(Linux)에서 baseline 생성 후 커밋. 머지 시 A1 잡이 골든을 자동 검증.

A1 머지 후 A2를 시작하면 A2 PR에서 골든 회귀가 자동으로 잡힌다.

---

## 7. 영향 범위

| 항목 | 영향 |
|---|---|
| `lib/` | 변경 없음 |
| `pubspec.yaml` | 변경 없음 (version bump 불필요) |
| `CHANGELOG.md` | 0.2.1 엔트리 불필요 (패키지 미배포) |
| `pub.dev` | 배포 없음 |
| `.github/workflows/test.yml` | 신규 |
| `test/shape_painter_golden_test.dart` | 신규 |
| `test/goldens/painter/*.png` | 신규 (12개 baseline) |
| `README.md` | Test 배지 추가 |

---

## 8. 관련 문서

- 로드맵: `docs/ROADMAP.md` (항목 C — CI 워크플로우, 항목 E — 골든 테스트)
- 0.2.0 spec: `docs/specs/2026-04-22-v0.2.0-platform-expansion-design.md`
