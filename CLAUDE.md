# pixel_ui — Claude Code 가이드

이 파일은 **Claude Code가 매 세션 자동 로드**하는 pixel_ui 저장소 전용 작업 규칙입니다. 사용자가 수동으로 설명하지 않아도 Claude가 이 프로젝트의 관행을 따르도록 합니다.

## 프로젝트 개요

**pixel_ui**: Flutter용 픽셀 아트 디자인 시스템 (프리미티브 + Mulmaru 폰트 번들).

- **pub.dev**: https://pub.dev/packages/pixel_ui
- **GitHub**: https://github.com/BottlePumpkin/pixel_ui
- **현재 버전**: 0.1.0 (첫 공개 배포 완료)
- **라이선스**: MIT (코드) + SIL OFL 1.1 (Mulmaru 폰트)
- **공개 API**: `PixelCorners`, `PixelShadow`, `PixelTexture`, `PixelShapeStyle`, `PixelShapePainter`, `PixelBox`, `PixelButton`, `PixelText` 네임스페이스
- **로드맵**: `docs/ROADMAP.md` 참조
- **설계 스펙**: `docs/specs/` 참조

## 신원 / 계정 (❗ 중요)

이 저장소 내부에서의 git·pub.dev 신원은 **반드시 개인 계정**이어야 합니다. 다른 계정(예: 회사/조직 이메일)으로 커밋·배포하지 마세요.

| 항목 | 값 |
|---|---|
| `git config user.name` | `BottlePumpkin` |
| `git config user.email` | `p4569zz@gmail.com` |
| pub.dev uploader | `p4569zz@gmail.com` (Google OAuth) |
| SSH remote alias | `git@github.com-BottlePumpkin:BottlePumpkin/pixel_ui.git` |

**SSH config**는 `~/.ssh/config`에 이미 다음과 같이 설정되어 있음:

```
Host github.com-BottlePumpkin
  HostName github.com
  IdentityFile ~/.ssh/id_ed25519_p4569zz
  User BottlePumpkin
```

**git remote URL은 반드시 alias 사용** (`git@github.com:...` 아님).

신원 검증은 `.claude/settings.json`의 SessionStart hook이 자동 수행 — 불일치 시 경고 노출.

## 배포 리듬 (버전 bump 시)

배포는 `v*.*.*` 태그 push 시 `.github/workflows/publish.yml`이 자동 수행한다. 수동 publish 명령은 실행하지 않는다.

```text
1. 코드 변경 → 테스트 추가/업데이트
2. (선택) 로컬 빠른 피드백: fvm flutter analyze && fvm flutter test --exclude-tags screenshot
3. pubspec.yaml version bump + CHANGELOG.md 엔트리 맨 위 추가
4. git commit -am "chore: bump version to X.Y.Z"
5. git tag -a vX.Y.Z -m "vX.Y.Z — summary"
6. git push origin main vX.Y.Z        # publish.yml 자동 시작
7. Actions 탭에서 워크플로 성공 확인
8. https://pub.dev/packages/pixel_ui 에서 새 버전·README·CHANGELOG 렌더링 확인
```

**자동 실행되는 검증**: tag↔pubspec 버전 일치 → `flutter analyze` → `flutter test --exclude-tags screenshot` → `dart pub publish --dry-run` → pub.dev 중복 배포 차단 → `dart pub publish --force` → `gh release create --generate-notes`.

**원칙**: `dart pub publish`는 취소 불가 (30일 retract만). CHANGELOG와 version bump를 신중히 검토한 뒤 태그 push.

**OIDC 인증**: `.github/workflows/publish.yml`의 `permissions: id-token: write`와 pub.dev Admin 탭의 Automated publishing 설정(`BottlePumpkin/pixel_ui`, tag pattern `v{{version}}`)이 함께 동작. 로컬 `pub-credentials.json` 의존성 없음.

## 파일 무결성 규칙

### 수정 금지

- `assets/fonts/Mulmaru.ttf` — OFL Reserved Font Name + copyright 메타데이터 훼손 위험. 업데이트가 필요하면 업스트림(mushsooni/mulmaru)에서 바이너리 그대로 교체, 재인코딩/최적화 금지
- `OFL.txt` — 업스트림 LICENSE 원문 1:1 반영. 직접 편집 대신 curl로 업스트림 재다운로드

### `publish_to: none` 유지

- `example/pubspec.yaml` — 쇼케이스 앱, pub.dev 업로드 불가
- `tuner/pubspec.yaml` — 웹 튜너, pub.dev 업로드 불가

실수로 제거하면 `dart pub publish` 시 공개되어 이름 충돌·혼란 발생.

## 잠재 함정

- **Hot restart ≠ 패키지 재해석**: 워크스페이스/path ↔ pub.dev 의존성 스위치 후에는 **반드시 cold `flutter run`**. `.dart_tool/flutter_build/<hash>/` 캐시가 옛 경로를 잡아 "Member not found" 발생 가능. 애매하면 `fvm flutter clean && flutter run`.
- **pub.dev retract 30일 한정**: 치명 버그 발견 시 30일 이내엔 `dart pub retract X.Y.Z` 가능, 이후엔 deprecate만. 보통은 즉시 hotfix 릴리스가 안전.
- **shields.io 배지 캐시**: README pub 버전 배지는 ~5분 캐시. 배포 직후 안 갱신 보여도 정상.
- **퍼블리셔 계정 잘못 연결**: pub.dev Admin → Automated publishing에 연결된 GitHub repo가 `BottlePumpkin/pixel_ui`인지 확인. 잘못된 계정/repo로 첫 publish되면 uploader 기록 영구 (retract로 버전은 내릴 수 있어도 uploader 변경 불가).

## 저장소 구조

```
pixel_ui/
├── lib/                    공개 패키지 소스
├── example/                iOS+Android 쇼케이스 (publish_to: none)
├── tuner/                  (계획) 웹 PixelShapeStyle 튜너, GitHub Pages 배포
├── assets/fonts/           Mulmaru.ttf (OFL 1.1)
├── test/                   단위·위젯 테스트
├── docs/
│   ├── ROADMAP.md          0.1.1+ 계획
│   └── specs/              설계 스펙
├── .github/workflows/      test.yml / build.yml / publish.yml
├── .claude/
│   └── settings.json       SessionStart hook (git identity)
├── LICENSE                 MIT + OFL 언급
├── OFL.txt                 SIL OFL 1.1 (Mulmaru)
├── README.md
├── CHANGELOG.md
└── pubspec.yaml
```

## 환경

- Flutter `>=3.32.0`, Dart SDK `^3.8.0`
- FVM 사용 권장 (`fvm flutter`/`fvm dart`)
- 평상시 배포는 publish.yml + OIDC가 담당, 로컬 `pub-credentials.json` 불필요. 응급 수동 publish가 필요한 경우에만 `dart pub login`으로 재로그인.

## 관련 문서

- **로드맵**: `docs/ROADMAP.md`
- **튜너 설계**: `docs/specs/2026-04-22-tuner-design.md`
- **배포 설계**: 모노레포의 `docs/superpowers/specs/2026-04-22-pixel-ui-publish-design.md`
