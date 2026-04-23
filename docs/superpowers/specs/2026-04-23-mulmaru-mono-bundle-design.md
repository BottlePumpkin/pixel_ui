# Mulmaru Mono Bundle — Design

- 작성일: 2026-04-23
- 브랜치: `feat/mulmaru-mono`
- 목표 버전: 0.2.0 → 0.2.1
- 원 로드맵 항목: `docs/ROADMAP.md` §D

## 배경

pixel_ui 0.1.0은 Proportional Mulmaru만 번들했다. ROADMAP §D는 코드/터미널/모노스페이스 UI 용도의 Mono 변형을 추가하기로 예약됐고, 사용자 요청이 들어오면 진행하기로 유보됐다. 이번 사이클에서 실행한다.

부가 효과: **이번 배포가 `publish.yml` 자동화의 첫 실전 tag push가 되어 OIDC → publish → GitHub Release 전체 플로우를 end-to-end 검증**한다.

## 목표

- 번들된 `MulmaruMono` family를 TextStyle 팩토리로 제공
- 기존 `PixelText.mulmaru(...)` API와 대칭되는 시그니처 유지 (학습 비용 0)
- 0.2.0과 non-breaking 호환 — 기존 사용자는 `^0.2.0`에서 자동 픽업

## 비목표

- **폰트 다운로드 자동화 스크립트**. 폰트 업데이트는 연 단위이고, 수동 한 번 다운로드로 충분.
- **기존 `Mulmaru.ttf` 재업로드**. v1.0 release의 `Mulmaru.ttf`와 SHA256 바이트 일치 (`02545e10…3138810`) 확인됨 — Proportional은 이미 최신.
- **Mono 전용 example 페이지·스크린샷**. README Typography 섹션 한 블록이면 충분. 0.1.1에서 추가한 4장 스크린샷은 그대로 유지.
- **폰트 서브셋팅/최적화**. OFL RFN·copyright 메타데이터 훼손 위험. 업스트림 바이너리 그대로 번들.

## 선결 조건

- `publish.yml`이 main에 병합됨 (PR #2, `a5b03a1`). ✓
- pub.dev Admin → Automated publishing 설정 완료 (`BottlePumpkin/pixel_ui`, tag pattern `v{{version}}`). ✓

## 폰트 수급

**소스**: `https://github.com/mushsooni/mulmaru/releases/download/v1.0/MulmaruMono.zip`

**zip 구성** (v1.0, 2025-11-23):

| 파일 | 크기 | 용도 |
|---|---:|---|
| `MulmaruMono.ttf` | 1,583,396 B | **번들 대상** |
| `MulmaruMono.otf` | 576,108 B | 불필요 (Flutter는 TTF 사용) |
| `MulmaruMono.pfp` | 1,247,927 B | 불필요 (PixelFont Project 독자 포맷) |
| `MulmaruMono.woff2` | 98,252 B | 불필요 (웹 전용) |
| `LICENSE.txt` | 4,547 B | 참조용 — 기존 `OFL.txt`와 동일 SIL OFL 1.1 |

**추출 절차** (수동, 1회):

```bash
cd /tmp
curl -fsSL -o MulmaruMono.zip "https://github.com/mushsooni/mulmaru/releases/download/v1.0/MulmaruMono.zip"
unzip -o MulmaruMono.zip MulmaruMono.ttf
mv MulmaruMono.ttf /path/to/pixel_ui/assets/fonts/
shasum -a 256 /path/to/pixel_ui/assets/fonts/MulmaruMono.ttf
# 예상: 34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d
rm MulmaruMono.zip
```

**SHA256 (provenance 기록용, CHANGELOG 엔트리에 포함)**:
`34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d`

**검증**: `pubspec.yaml`의 `fonts` 섹션에 등록하여 example 앱에서 렌더링 확인. OFL.txt는 이미 배포에 포함되므로 추가 라이선스 파일 불필요.

## API 설계

### 추가되는 공개 표면

`lib/src/pixel_text.dart`의 `PixelText` 추상 클래스에 추가:

```dart
/// Font family name of the bundled Mulmaru Mono (monospaced) font.
static const String mulmaruMonoFontFamily = 'MulmaruMono';

/// Returns a [TextStyle] configured for the bundled Mulmaru Mono pixel font.
///
/// Identical semantics to [mulmaru] — see that method for shadow resolution
/// rules and default justification.
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

**설계 결정**:

- **시그니처 대칭**: `mulmaru()`와 동일 파라미터 이름·순서·기본값·shadow 해결 규칙. 사용자는 두 factory 중 어느 것이든 동일한 mental model로 호출 가능.
- **package 상수 공유**: `mulmaruPackage`(= `'pixel_ui'`)를 재사용. 별도 상수 불필요.
- **DRY 위반 유예**: shadow 해결 블록이 `mulmaru()`와 중복이지만, private helper로 추출하면 API docs 생성 시 noise 증가. 9줄 중복은 가독성·독립성이 이득.

### pubspec.yaml 변경

```yaml
flutter:
  fonts:
    - family: Mulmaru
      fonts:
        - asset: assets/fonts/Mulmaru.ttf
    - family: MulmaruMono        # 추가
      fonts:
        - asset: assets/fonts/MulmaruMono.ttf
```

`version`: `0.2.0` → `0.2.1`.

## 테스트

`test/pixel_text_test.dart`에 추가:

```dart
test('mulmaruMono() returns TextStyle with MulmaruMono font', () {
  final style = PixelText.mulmaruMono(fontSize: 16);
  expect(style.fontFamily, 'MulmaruMono');
  expect(style.package, 'pixel_ui');
  expect(style.height, 1.0);
  expect(style.color, const Color(0xFF000000));
});

test('mulmaruMono() with shadowColor produces single shadow', () {
  final style = PixelText.mulmaruMono(shadowColor: const Color(0xFF808080));
  expect(style.shadows, hasLength(1));
  expect(style.shadows!.first.color, const Color(0xFF808080));
  expect(style.shadows!.first.offset, const Offset(1, 1));
});

test('mulmaruMono() with explicit shadows ignores shadowColor/shadowOffset', () {
  final explicit = [const Shadow(offset: Offset(2, 2), color: Color(0xFFFF0000))];
  final style = PixelText.mulmaruMono(
    shadowColor: const Color(0xFF808080),
    shadowOffset: const Offset(3, 3),
    shadows: explicit,
  );
  expect(style.shadows, explicit);
});
```

기존 `mulmaru()` 테스트 패턴과 동일한 3개 케이스 (basic, shadowColor shortcut, explicit shadows). 골든 테스트는 폰트 렌더링 변화 가능성이 있어 도입하지 않음.

## 문서 업데이트

### README.md

두 곳 수정:

**1. `### Typography` 섹션 (line 127–146)**: 기존 Mulmaru 예시 블록 뒤에 Mono 서브섹션 추가. 기존 예시는 그대로 유지.

```markdown
#### Monospaced variant

For code, terminal-style UI, or fixed-width layouts, use `PixelText.mulmaruMono`:

[triple-backtick]dart
Text(
  'HP 042/100',
  style: PixelText.mulmaruMono(fontSize: 12, color: Colors.white),
)
[triple-backtick]
```

**2. `## Bundled Font` 섹션 (line 167)**: 본문에서 단수형을 복수형으로 바꾸고 Mono 언급 추가.

변경 전: `This package bundles the [Mulmaru](...) pixel font by **mushsooni**, ...`

변경 후: `This package bundles the [Mulmaru](...) pixel fonts (proportional + monospaced variants) by **mushsooni**, ...`

### CHANGELOG.md

맨 위에 신규 엔트리 추가:

```markdown
## 0.2.1 — 2026-04-23

- Add bundled `MulmaruMono` font family (SIL OFL 1.1).
- Add `PixelText.mulmaruMono(...)` factory with signature identical to `PixelText.mulmaru(...)`.
- Font source: [mushsooni/mulmaru v1.0 release](https://github.com/mushsooni/mulmaru/releases/tag/v1.0). SHA256 `34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d`.
```

### docs/ROADMAP.md (piggyback 정리 포함)

**§D 상태 갱신**: "0.2.0 로드맵" → "완료됨 (0.2.1, 2026-04-23)" 표기.

**우선순위 리스트** 하단의 번호 리스트에서 D 완료 반영.

**M3 정리 (Section A, lines 13-86)**: "🎯 0.1.1 — 가장 가까운 다음 배포" 섹션 전체를 "0.1.1 — 완료 (2026-04-22, 스크린샷)"로 축약. 원래 11줄 배포 스크립트 블록은 제거 (자동화된 신규 리듬과 모순).

**M4 정리 (Section C, lines 91-128)**: "🎯 0.2.0 로드맵 → C. CI 워크플로우 추가"를 "완료됨 (PR #1 `test.yml` + platform build matrix + PR #2 `publish.yml`)"로 축약. 원래 ci.yml 스텝 블록은 제거 (실제 shipped된 test.yml과 구성이 다름).

## 릴리스 플로우 (자동화 첫 실전 검증)

```text
1. feat/mulmaru-mono 브랜치에서 모든 변경 커밋
2. 로컬 sanity: fvm flutter analyze && fvm flutter test --exclude-tags screenshot
3. PR 생성, 리뷰, main으로 squash merge
4. main 체크아웃, pull
5. git tag -a v0.2.1 -m "v0.2.1 — bundle Mulmaru Mono"
6. git push origin main v0.2.1
7. GitHub Actions 탭에서 publish.yml 실행 관찰:
   - tag↔pubspec 체크 (0.2.1 == 0.2.1 ✓)
   - analyze + test 통과
   - pub publish --dry-run 통과
   - pub.dev 중복 가드 통과 (0.2.1 신규)
   - OIDC publish --force 성공
   - gh release create 성공
8. https://pub.dev/packages/pixel_ui 에서 0.2.1 렌더링 확인
9. https://github.com/BottlePumpkin/pixel_ui/releases/tag/v0.2.1 에서 Release 확인
```

**자동화 실패 시 복구**:

| 실패 지점 | 영향 | 복구 |
|---|---|---|
| analyze/test | pub.dev 상태 변화 없음 | 코드 수정 후 hotfix 커밋 → 새 태그 `v0.2.1-rc.1` (기존 태그 삭제 후 재push는 트리거 미반복 주의) |
| OIDC 인증 | pub.dev 상태 변화 없음 | pub.dev Admin 설정 재확인, 필요 시 repo/tag pattern 수정 |
| pub publish | pub.dev 일부 state 가능 | 로그 확인, retract 여부 판단, hotfix `v0.2.2` |
| gh release | pub.dev는 배포됨, GitHub Release만 미생성 | 수동: `gh release create v0.2.1 --generate-notes` |

## 결정 요약

| 주제 | 결정 |
|---|---|
| 버전 번프 | 0.2.0 → 0.2.1 (Dart pre-1.0 관례, `^0.2.0` 자동 픽업) |
| 폰트 수급 | v1.0 release zip에서 TTF만 수동 추출, 기타 파일·스크립트 없음 |
| API 네이밍 | `mulmaruMono()` + `mulmaruMonoFontFamily` (기존 `mulmaru()` 대칭) |
| 테스트 | 3개 단위 테스트, 골든 미포함 |
| README | Typography 한 블록 |
| ROADMAP | §D 완료 + M3/M4 스테일 섹션 정리 piggyback |
| 릴리스 | 태그 push → publish.yml 자동 실행 (첫 실전 검증) |
