# pixel_ui Publish Automation — Design

- 작성일: 2026-04-23
- 브랜치: `feat/publish-automation`
- 참조: `/Users/byeonghopark-jobis/dev/rfw_gen/.github/workflows/publish.yml`

## 배경

현재 pixel_ui 배포는 전적으로 수동이다 (CLAUDE.md:37-53, ROADMAP.md:324-340). 매 릴리스마다:

1. 로컬에서 `fvm flutter analyze && fvm flutter test`
2. `dart pub publish --dry-run` 경고 0 확인
3. `pub-credentials.json`의 로그인 이메일이 `p4569zz@gmail.com`인지 확인
4. `dart pub publish` 실행
5. `git tag` + `git push origin main vX.Y.Z`

실수 지점이 많다 — 특히 퍼블리셔 계정을 회사 계정으로 잘못 로그인한 채 publish하면 첫 uploader 기록이 영구 박힘. 이 위험을 pub.dev의 **GitHub Actions OIDC 자동 배포**로 제거한다.

## 목표

- 태그 push 한 번으로 analyze → test → dry-run → publish → GitHub Release 생성까지 자동 실행
- OIDC 기반 인증 → 로컬 `pub-credentials.json` 의존 제거
- 중복 배포·버전 불일치·품질 실패를 publish **이전에** 하드 페일로 잡음

## 비목표

- **CHANGELOG.md 자동 생성 안 함**. pub.dev Versions 탭은 CHANGELOG를 그대로 렌더링하므로 큐레이션된 내러티브를 유지. release-please 같은 도구 도입은 릴리스 빈도가 주 1회 이상이 될 때 재검토.
- **version bump 자동화 안 함**. 수동 bump는 배포 의도의 명시적 신호.
- **멀티 플랫폼 publish runner 안 씀**. build.yml은 빌드 가능 여부 검증, publish는 ubuntu 한 대면 충분.
- **workflow_dispatch 트리거 추가 안 함**. 태그가 유일한 배포 신호 — 수동 트리거 가능성이 오발사를 만듦.

## 선결 조건

- pub.dev Admin 탭 → Automated publishing에서 `BottlePumpkin/pixel_ui` repo + tag pattern `v{{version}}` 등록 완료. (사용자 확인됨, 2026-04-23)

## 최종 리듬

```
1. 코드 변경 + 테스트 추가
2. (선택) 로컬 fvm flutter analyze && fvm flutter test --exclude-tags screenshot
3. pubspec.yaml version bump + CHANGELOG.md 엔트리 (맨 위)
4. git commit
5. git tag -a vX.Y.Z -m "vX.Y.Z — summary"
6. git push origin main vX.Y.Z       ← publish.yml 자동 시작
7. Actions 탭에서 워크플로 성공 확인
8. https://pub.dev/packages/pixel_ui 새 버전 렌더링 확인
```

**사라지는 단계**: 로컬 dry-run(CI가 함), credentials 이메일 확인(OIDC), 로컬 publish 명령.

## 워크플로 설계

### 파일

`.github/workflows/publish.yml` (신규). 기존 `test.yml`, `build.yml`은 손대지 않음.

### 트리거

```yaml
on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+*'
```

- 태그 regex는 `v0.2.1`·`v0.2.1-beta` 둘 다 매칭 (pre-release 대비).
- 브랜치/PR 트리거 없음.

### 권한

```yaml
permissions:
  id-token: write   # pub.dev OIDC
  contents: write   # gh release create
```

### 스텝 구성

순서가 곧 안전장치 — 앞 단계 실패 시 뒤 단계로 진행하지 않음.

1. **Checkout + Flutter setup** — `flutter-version: '3.32.7'` (test.yml·build.yml과 동일 핀)
2. **Verify tag matches pubspec version** — 태그에서 `v` 떼고 pubspec.yaml의 `version:` 필드와 문자열 비교, 불일치 시 hard fail
3. **`flutter pub get`**
4. **`flutter analyze`** — 기존 test.yml과 동일 게이트
5. **`flutter test --exclude-tags screenshot`** — painter golden은 포함, screenshot golden은 CI runner 편차로 제외 (메모리: screenshot goldens CI 제외 규칙)
6. **`dart pub publish --dry-run`** — 경고/에러 확인
7. **Guard against re-publish** — pub.dev API(`https://pub.dev/api/packages/pixel_ui`)에 해당 버전이 이미 있으면 hard fail. dry-run은 이 검사를 하지 않으므로 별도 스텝 필요
8. **`dart pub publish --force`** — OIDC 인증. `--force`는 대화형 확인 스킵 (CI는 input 불가)
9. **`gh release create "$GITHUB_REF_NAME" --generate-notes --title "$GITHUB_REF_NAME"`** — PR/커밋 기반 자동 노트

### 실패 시 동작

- 게이트(2-6) 실패 → publish 스텝 미실행 → pub.dev 상태 변화 없음
- Guard(7) 실패 → 태그 중복 실수 신호, publish 안 됨
- Publish(8) 실패 → Release 생성 안 함 (pub.dev는 일부 상태로 남을 수 있음, 이 경우 수동 조사 후 재시도 또는 retract)

## 문서 업데이트

배포 리듬이 바뀌므로 기존 문서 정비 필요.

### CLAUDE.md

"배포 리듬 (버전 bump 시)" 섹션을 위 "최종 리듬"으로 교체. 기존 10단계 수동 블록 삭제.

### docs/ROADMAP.md

"공통 배포 리듬 (모든 버전 공통)" 섹션을 교체. 단순 리듬으로 축약하고 "세부는 CLAUDE.md 참조" 링크 추가.

0.2.0 로드맵 섹션에 **C. CI 워크플로우 추가**는 이미 test.yml로 완료. 이번 자동화는 별도 항목으로 기록할지 사용자 선택에 맡김 (범위 밖).

## 검증 전략

이번 사이클에서는 실제 publish를 수행하지 않는다.

**이유**:
- 단순 인프라 변경을 pub.dev에 빈 version bump로 올리는 것은 semver 위생에 반함 (`.github/` 디렉터리는 pub 패키지에 포함되지 않음 → 사용자 변경 0)
- 워크플로의 게이트 체인이 대부분의 설정 오류를 publish 이전에 잡음
- 다음 실질 변경(예: 0.2.1 버그픽스, 0.3.0 Mulmaru Mono)이 생기면 그 배포로 end-to-end 자동 검증

**예상 실패 모드와 대응**:
- OIDC 인증 실패: pub.dev publisher 설정 재확인, 필요시 repo/tag pattern 수정
- Publish 직전 guard의 API 응답 형식 변경: 다음 릴리스에서 수정 PR
- `--force`가 거부되는 경우: OIDC fresh token 요구 케이스 확인

실패 시 pub.dev retract(30일 내) 또는 hotfix 배포로 복구.

## 결정 요약

| 주제 | 결정 |
|---|---|
| 트리거 | 태그 push만 (`v[0-9]+.[0-9]+.[0-9]+*`) |
| 인증 | pub.dev OIDC (이미 설정됨) |
| 게이트 | analyze + test(--exclude-tags screenshot) + dry-run + tag↔pubspec 일치 |
| 재실행 중복 | pub.dev API 조회 후 hard fail |
| Release 노트 | `--generate-notes` (자동), CHANGELOG.md는 수동 유지 |
| Flutter 버전 | `3.32.7` (기존 workflow와 통일) |
| 이번 사이클 범위 | publish.yml 추가 + CLAUDE.md/ROADMAP.md 리듬 섹션 업데이트. 실제 publish는 다음 실질 릴리스 때 |
