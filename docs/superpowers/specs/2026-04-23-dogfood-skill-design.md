# Dogfood Skill 설계

**작성일**: 2026-04-23
**브랜치**: `feat/dogfood-skill`
**기반 참조**: `BottlePumpkin/rfw_gen`의 `.claude/skills/dogfood/SKILL.md`

## 1. 목적과 철학

pixel_ui의 **첫 사용자를 매 사이클 시뮬레이션**해 — 문서만 읽은 개발자, 소스까지 읽을 수 있는 베테랑 등 — 실제 사용 중 발생하는 DX 마찰·버그·위젯 부재를 발굴하고, GitHub Issue로 기록해 지속적으로 고도화한다. 없는 위젯은 새로 추가되고, 불편한 API는 개선된다. pixel_ui 자체의 품질을 사용 경험으로부터 끌어올리는 자가 피드백 루프.

이 문서는 두 Claude Code slash command (`/dogfood run`, `/dogfood fix`)로 구성된 스킬의 설계를 정의한다.

## 2. 확정된 설계 결정

브레인스토밍 과정에서 합의된 핵심 선택지:

| 항목 | 선택 | 이유 |
|---|---|---|
| Throwaway 앱 위치 | 매 사이클 `dogfood_cycle_{N}/` 생성 후 폐기 | 진짜 신규 프로젝트 경험 재현 |
| 페르소나 | 혼합 3종 (정보 제약 × 사용 목적) | rfw_gen 원리 유지 + pixel_ui의 두 가지 사용 맥락 커버 |
| 없는 위젯 처리 | `feature` + `widget-gap` 이중 라벨 + Fix fast-track + 8-항목 구현 체크리스트 | 사용자 주요 성장 벡터를 구조적으로 강조 |
| Tuner 커버리지 | 자동 스크립트 (`tool/check_tuner_coverage.dart`) | drift 즉시 탐지 |
| 커버리지 구현 접근 | **정규식 + 네이밍 컨벤션** (후일 AST로 진화 가능) | YAGNI: 현재 14개 필드 규모에 충분 |
| 이슈 저장 | GitHub Issues + `dogfood` 라벨 | 단일 트래커, `gh` CLI 활용 |
| 스킬 위치 | `.claude/skills/dogfood/` | 저장소 이전성, slash command 자동 로드 |
| Tuner drift 이슈 수 | 사이클당 **1개 집계 이슈** (quota 밖) | 페르소나 발견 신호 보존 + drift 폭주 방지 |

## 3. 페르소나 3종

매 Run 사이클 랜덤 1명 선택. 기억 가능한 경우 직전 사이클 페르소나와 연속 회피.

### C1 — 게임 UI 신규 사용자

**프로필**: Flutter 경력자, pixel_ui 처음. RPG/로그라이크 같은 레트로 게임 UI가 목표.

**정보 접근**:
- 허용: pub.dev 페이지 (README 렌더), `README.md`, `pubspec.yaml`
- 금지: `lib/` 소스, `doc/screenshots/`, `tuner/`, `docs/`, `CHANGELOG.md`, `example/`

**행동**: pub.dev 설치 가이드 따라 시작 → README 예제 변형 → HP 바/인벤토리 슬롯/대화창 같은 게임 UI 패턴 맨땅에서 구성.

**기대 이슈 유형**: `docs` (README 부족), `dx` (첫 30분 마찰), `feature`+`widget-gap` (PixelProgressBar, PixelIconButton, PixelDialog 등).

**의존성 모드**: 50% 확률로 `pixel_ui: ^<pub.dev latest>` (실제 신규 사용자 경험 재현), 50% 확률로 `path: ../` (unreleased 검증). 선택 결과는 사이클 요약에 기록.

### C2 — 앱 UI 문서 독자

**프로필**: Flutter 경력자, pixel_ui 공식 문서를 읽음. 일반 앱(설정/프로필/목록)에 픽셀 미감만 입히고 싶음.

**정보 접근**:
- 허용: C1의 것 전부 + `CHANGELOG.md`, `doc/screenshots/`, README Gallery, `tuner/` 실제 사용, pub.dev Example 탭
- 금지: `lib/` 소스, `example/lib/` 소스

**행동**: 문서·Gallery로 API 범위 파악 → tuner에서 `PixelShapeStyle` 튜닝 후 값 복사 → 설정/프로필/목록 같은 앱 UI 패턴 구현.

**기대 이슈 유형**: `dx` (tuner 설정값과 실제 렌더 불일치), `tuner`+`stale`/`missing`, `feature`+`widget-gap` (PixelSwitch, PixelTextField, PixelCard, PixelListTile), `docs` (API doc 예제 부재).

**의존성 모드**: 항상 `path: ../`.

### C3 — 픽셀 아트 베테랑

**프로필**: 픽셀 아트 렌더링 원리 이해, Flutter Canvas API 경험, 소스까지 읽음. 엣지 케이스 사냥꾼.

**정보 접근**: 전부 (소스·테스트·internal 문서).

**행동**: 비대칭 corners, negative shadow offset, 극단 logicalWidth/Height, 텍스처 타일링 경계, RTL → golden diff 확인 → 내부 페인팅 로직 검토해 버그 가설.

**기대 이슈 유형**: `bug` (엣지 케이스 렌더 오류), `feature` (원리적으로 자연스러운 확장 — 그라디언트 fill 등), `upstream` (Flutter Canvas/렌더러 한계).

**의존성 모드**: 항상 `path: ../`.

## 4. 사이클 디렉토리 정책

### 4.1 네이밍과 생성

- `dogfood_cycle_{N}/` — 프로젝트 루트 직속
- `flutter create dogfood_cycle_{N} --project-name dogfood_cycle_{N}`
- `.gitignore`에 `dogfood_cycle_*/` 패턴 추가 (prereqs 자동 체크)

### 4.2 정리 정책

- Run 시작 시 `rm -rf dogfood_cycle_*/` — **마지막 사이클만 유지, 직전 것도 삭제**
- 이유: 모든 산출물(Dart 코드·빌드 결과·에러 로그)은 GitHub Issue body에 코드 블록으로 삽입돼 영구 기록됨. 로컬 디렉토리는 임시 작업공간일 뿐.
- 예외: `/dogfood run --keep` 플래그는 삭제 스킵 (디버깅용)

### 4.3 pubspec 의존성

C1의 50% 분기를 제외하면 모두 로컬 path 참조:

```yaml
dependencies:
  flutter: { sdk: flutter }
  pixel_ui:
    path: ../
```

C1 pub.dev 분기 시:

```yaml
dependencies:
  flutter: { sdk: flutter }
  pixel_ui: ^<LATEST>  # pub.dev에서 최신 버전 조회
```

## 5. 앱 주제 풀 (15개)

페르소나 친화도 태그 포함. Run 시 과거 이슈 body의 `주제:` 파싱해 중복 회피, 친화 페르소나와 매칭되는 것 우선.

| # | 주제 | 친화 페르소나 | 핵심 위젯 후보 |
|---|---|---|---|
| 1 | RPG 인벤토리 그리드 | C1, C3 | PixelBox 중첩, asymmetric corners |
| 2 | 전투 HP/MP 바 | C1 | PixelBox + 텍스처 + (widget-gap) PixelProgressBar |
| 3 | NPC 대화창 | C1, C2 | PixelBox (topTab), PixelText, (widget-gap) PixelDialog |
| 4 | 로그라이크 미니맵 | C3 | PixelShapePainter 직접, CustomPaint 통합 |
| 5 | 픽셀 설정 스크린 | C2 | (widget-gap) PixelSwitch, PixelSlider, PixelListTile |
| 6 | 게임 타이틀 화면 | C1, C2 | PixelButton 큰 사이즈, PixelText 그림자 |
| 7 | 프로필 카드 | C2 | (widget-gap) PixelCard, PixelAvatar |
| 8 | 픽셀 스타일 할일 앱 | C2 | (widget-gap) PixelCheckbox, PixelTextField |
| 9 | 레트로 계산기 | C1 | PixelButton 그리드, PixelText Mono |
| 10 | 픽셀 가계부 카드 | C2 | PixelBox, PixelText (숫자), (widget-gap) PixelDivider |
| 11 | 몬스터 도감 그리드 | C1, C2 | 스크롤 + PixelBox + PixelText |
| 12 | 캐릭터 스탯 시트 | C1, C3 | PixelText 정렬, PixelShadow 계층 |
| 13 | 픽셀 음악 플레이어 | C2 | (widget-gap) PixelIconButton, PixelSlider |
| 14 | 퀘스트 로그 리스트 | C1 | PixelBox 리스트, PixelText 말줄임 |
| 15 | 픽셀 알림 토스트 | C2 | (widget-gap) PixelToast, PixelShadow 애니메이션 |

## 6. 위젯 커버리지 규칙

### 6.1 최소 요구 (페르소나별)

- **C1·C2**: 공개 API 최소 4개 사용 (`PixelBox` / `PixelButton` / `PixelText` / `PixelShapeStyle` 조합)
- **C3**: 엣지 케이스 최소 3개 시도 (비대칭 corners / 네거티브 shadow offset / 극단 logicalWidth)

### 6.2 권장

- 레이아웃(스크롤/그리드/열) + 인터랙션(터치/입력) 둘 다 포함
- 주제가 "없는 위젯"을 암시하면 반드시 Flutter 기본 위젯으로 fallback 구현 시도 → 이 고통이 `widget-gap` 이슈의 증거

## 7. 고통 기록 프로토콜

### 7.1 3-튜플

페르소나가 마찰을 만날 때마다 기록:

- **시도**: 무엇을 해보았나
- **기대**: 어떻게 동작할 줄 알았나
- **실제**: 실제로 뭐가 일어났나

### 7.2 스크린샷

시각적 버그(픽셀 어긋남, 그림자 어색함, 텍스처 경계)는 텍스트로 설명 불가. Issue body에 `![](screenshots/NNN.png)` 첨부 또는 ASCII-art diagram.

### 7.3 내부 로그

이슈화 전 raw 수집용: `dogfood_cycle_{N}/NOTES.md` (Markdown 자유 형식).

## 8. 이슈 분류 · 라벨 체계

### 8.1 1차 라벨 (`dogfood` + 아래 중 1개)

| 라벨 | 색상 | 언제 쓰나 |
|---|---|---|
| `bug` | `#D73A4A` | 렌더 오류, 크래시, 잘못된 출력 |
| `dx` | `#D93F0B` | API 불편, 에러 메시지 불친절 |
| `feature` | `#A2EEEF` | 기능 확장 제안 |
| `docs` | `#0075CA` | README/API doc 개선 |
| `upstream` | `#BFD4F2` | Flutter/Canvas 한계 (이슈 대신 `docs/upstream/` 파일) |

### 8.2 2차 라벨 (optional)

| 라벨 | 색상 | 함께 쓰는 1차 | 의미 |
|---|---|---|---|
| `widget-gap` | `#5319E7` | `feature` | 없는 위젯 요청 (fast-track 대상) |
| `tuner` | `#FBCA04` | `dx` / `docs` / `bug` | tuner 관련 |
| `stale` | `#CCCCCC` | `tuner` | 컨트롤은 있으나 동작 이상 |
| `missing` | `#EEEEEE` | `tuner` | 공개 필드인데 컨트롤 부재 |

### 8.3 라벨 자동 생성 (Prereqs)

```bash
gh label create dogfood    --color 0E8A16 --description "Dogfood cycle issue"                 2>/dev/null || true
gh label create bug        --color D73A4A --description "Something isn't working"              2>/dev/null || true
gh label create feature    --color A2EEEF --description "New feature or request"               2>/dev/null || true
gh label create docs       --color 0075CA --description "Improvements or additions to documentation" 2>/dev/null || true
gh label create dx         --color D93F0B --description "Developer experience issue"           2>/dev/null || true
gh label create widget-gap --color 5319E7 --description "Missing widget request"               2>/dev/null || true
gh label create tuner      --color FBCA04 --description "Tuner-related"                        2>/dev/null || true
gh label create stale      --color CCCCCC --description "Outdated content"                     2>/dev/null || true
gh label create missing    --color EEEEEE --description "Missing coverage"                     2>/dev/null || true
gh label create upstream   --color BFD4F2 --description "Upstream Flutter limit"               2>/dev/null || true
```

`bug`, `feature`, `docs`는 GitHub 기본 제공 가정이 실제 빈 레포에선 깨지는 경우가 있어(cycle #1에서 확인), prereqs에서 idempotent로 함께 생성.

### 8.4 외부 기여자 필터 안내

README 이슈 탭 안내에 포함:

```markdown
[View user issues only](https://github.com/BottlePumpkin/pixel_ui/issues?q=is%3Aopen+-label%3Adogfood)
```

## 9. Widget-gap Fast-track

### 9.1 우선순위

Fix 모드 정렬 순서:

```
1. widget-gap (사용자 주요 성장 벡터, 상단 분리 표시)
2. bug
3. dx
4. feature (widget-gap 아닌 것)
5. docs
```

### 9.2 구현 체크리스트 (8-항목, PR 머지 조건)

```markdown
### Widget-gap 구현 체크리스트
- [ ] API 설계 기록: `docs/widgets/pixel_{name}.md` 또는 PR description에 시그니처·사용 예제 작성
- [ ] 공개 API 노출: `lib/pixel_ui.dart` export 추가
- [ ] 단위 테스트: `test/pixel_{name}_test.dart`
- [ ] 골든 테스트: 최소 1개 시각 회귀 방지
- [ ] README Gallery 갱신: 새 위젯 스크린샷 + 코드 예제
- [ ] CHANGELOG 엔트리: "Added" 섹션 추가
- [ ] example 쇼케이스 반영: 필요 시 `example/lib/`에 데모 추가
- [ ] tuner 대상 여부 판단: 시각 파라미터 있으면 tuner 컨트롤 추가 (별도 이슈 분리 가능)
```

## 10. Upstream 이슈 템플릿

`docs/upstream/{short-name}.md`:

```markdown
# {제목}

## 상태
수집됨 | 추적 중 | Flutter 이슈 연결됨 | 해결됨

## 증상
{사용자 관점 설명}

## 재현

### 입력 (pixel_ui 사용 코드)
\```dart
PixelBox(...)
\```

### 기대 결과
{설명 또는 이미지}

### 실제 결과
{에러 / 잘못된 렌더 스크린샷}

## 원인 분석
- **영역**: Flutter SDK / Canvas / Skia / 렌더러
- **원인**: {왜 pixel_ui 자체 수정으로 해결 불가한가}

## 회피책 (pixel_ui 수준)
{있으면 문서화 대상, 없으면 "없음"}

## 연관 링크
- 발견 경로: dogfood cycle #N, 페르소나 {X}
- Flutter Issues: (있으면 링크)
```

`docs/upstream/README.md`의 "수집됨" 섹션에 한 줄 요약 링크 추가.

## 11. Tuner 커버리지 스크립트

### 11.1 위치와 실행

- 파일: `tool/check_tuner_coverage.dart`
- 실행: `dart run tool/check_tuner_coverage.dart [--json]`
- Exit code: 0 (OK), 1 (누락/drift 있음)

### 11.2 대상 타입 (현재 기준)

```dart
const List<String> targetTypes = [
  'PixelCorners',
  'PixelShadow',
  'PixelTexture',
  'PixelShapeStyle',
];
```

총 14개 공개 필드. 향후 `PixelText` 튜너 탭 추가 시 이 리스트 확장.

### 11.3 커버리지 모델

- 각 공개 필드는 `tuner/lib/**/*.dart` 아래 어떤 `.dart` 파일이든 **필드 식별자**를 whole word로 참조하거나 **enclosing 타입**(`PixelCorners`, `PixelShadow`, ...)을 참조하면 "covered"로 간주. 타입 참조 fallback으로 composite 컨트롤(예: 프리셋 기반 `corner_picker.dart`)도 자연스럽게 필드 크레딧.
- "orphan"은 `tuner/lib/src/controls/` 밑 컨트롤 파일이 어떤 target field/type도 언급하지 않을 때. `home_page.dart`, `tuner_state.dart` 같은 non-control infra는 커버리지에는 기여하지만 orphan 판정 대상 아님.
- 권장(계약 아님) 파일 네이밍: `tuner/lib/src/controls/{topic}_picker|editor|slider|input.dart` (예: `corner_picker.dart`, `shadow_editor.dart`). 네이밍 자체를 스캐너가 강제하지는 않음.

### 11.4 접근 방식

**정규식 기반** (초기):

- 공개 필드: `lib/src/pixel_style.dart`에서 `final\s+<Type>\s+<name>;` 정규식 추출 (대상 타입 범위 내만)
- 컨트롤/infra: `tuner/lib/**`의 `.dart` 파일 전체를 재귀 스캔
- 필드 식별자 whole-word 매칭 + 타입 이름 whole-word 매칭 → 타입별 필드 집합 전개(union)
- orphan 판정은 `tuner/lib/src/controls/` 경로의 파일에만 적용

후일 파일 분산·복잡도 증가 시 `package:analyzer` 기반 AST로 교체 (구현 세부 변경, 스펙 불변).

### 11.5 출력 형식

```
✅ Covered (N):
  - PixelCorners.tl → corners/tl.dart
  ...

❌ Missing (N):
  - PixelTexture.seed → (no control found)

⚠️ Orphan controls (N):
  - controls/unused_gradient_picker.dart → (no matching public field)
```

### 11.6 자동 이슈 통합

Drift 발견 시:

- **1개 집계 이슈** 파일링 (사이클당, quota 밖):
  - 제목: `[dogfood/tuner] Coverage drift (cycle #N)`
  - 라벨: `dogfood,dx,tuner`
  - Body: missing/orphan 체크리스트
- 기존 open drift 이슈가 있으면 신규 생성 대신 **comment 추가**: `cycle #N에서도 감지됨`
- 동일 drift가 3사이클 연속 open이면 자동으로 `priority-high` 라벨 추가 (외면 방지)

## 12. Run 모드 — 11 스텝

### 12.1 인자

- `/dogfood run` — 기본 사이클
- `/dogfood run --keep` — 사이클 디렉토리 삭제 스킵

### 12.2 Prerequisites

1. git identity 검증 (SessionStart hook 재확인)
2. `gh auth status`
3. 라벨 생성 (섹션 8.3)
4. `.gitignore`에 `dogfood_cycle_*/` 추가 확인, 없으면 추가 후 커밋

### 12.3 스텝

**Step 1 — 이전 사이클 정리**: `rm -rf dogfood_cycle_*/` (단 `--keep`이면 스킵)

**Step 2 — 사이클 번호 결정**: `gh issue list --label dogfood --state all --limit 200 --json body -q '.[].body'` → `사이클: #N` 파싱 → max+1. 이슈 없으면 #1.

**Step 3 — 페르소나 랜덤 선택**: C1/C2/C3 중 1명. 직전 연속 회피. C1은 50/50 pub.dev vs path 분기.

**Step 4 — 주제 선택**: 섹션 5의 15개 풀 중 친화 페르소나 매칭 우선, 과거 중복 회피.

**Step 5 — 디렉토리 생성**: `flutter create dogfood_cycle_{N}` → pubspec 작성 → `flutter pub get`. 실패 시 에러 자체를 이슈로 파일링 후 사이클 중단.

**Step 6 — 페르소나 시뮬레이션 개발**: 섹션 3의 정보 접근 제약 엄격 준수. 섹션 6의 최소 커버리지 달성. 섹션 7의 3-튜플로 마찰 기록 (`NOTES.md`).

**Step 7 — Tuner 커버리지 스크립트 실행**: `dart run tool/check_tuner_coverage.dart --json > /tmp/tuner_drift_{N}.json`. 결과를 섹션 11.6 규칙으로 집계.

**Step 8 — 이슈 분류 · 우선순위**: 섹션 8.1 라벨로 분류. `bug > dx > feature(widget-gap 우선) > docs` 정렬. max 7개 quota. 초과는 "deferred"로 summary에 기록.

**Step 9 — 중복 검사**: `gh issue list --label dogfood --state open --json title,number,body`. 제목·키워드 유사도 비교. 명백 중복은 스킵 + "중복 스킵" 섹션 기록.

**Step 10 — Upstream 격리 & GitHub Issue 파일링**

- 10a. `upstream` 분류: `docs/upstream/{slug}.md` 생성 + `docs/upstream/README.md` 업데이트. GitHub Issue는 파일링하지 않음.
- 10b. 페르소나 이슈:
  ```bash
  gh issue create \
    --title "[dogfood/{category}] {summary}" \
    --label "dogfood,{category}{,widget-gap if applicable}" \
    --body "$(cat <<'EOF'
  ## 발견 컨텍스트
  - 사이클: #{N}
  - 주제: {topic}
  - 페르소나: {persona_name}
  - 의존성 모드: {path | pub.dev ^x.y.z}

  ## 문제
  {시도 + 기대 + 실제}

  ## 재현
  {단계}

  ## 스크린샷
  {있으면}

  ## 제안 해결
  {있으면}

  ## 영향
  - 공개 API: {list}
  - 파일: {list}
  EOF
  )"
  ```
- 10c. Tuner drift 집계 이슈: 섹션 11.6. 기존 open drift 있으면 comment로 대체.

**Step 11 — 사이클 요약 출력**:

```
## Dogfood Cycle #{N} Summary

📋 주제: {topic}
🎭 페르소나: {name} ({C1/C2/C3})
📦 의존성: {path | pub.dev ^x.y.z}
🎯 커버 위젯: {list} ({count}개)

### 파일링된 Persona 이슈 ({filed}/{discovered})
| # | 카테고리 | 이슈 | GitHub |

### Widget-gap 이슈 (fast-track 대상)
| # | 위젯 | GitHub |

### Tuner Drift ({status})
(새 이슈 #N) | (기존 #M 코멘트) | (drift 없음 ✅)

### Upstream ({count}건, docs/upstream/)
| # | 이슈 | 파일 |

### Deferred ({count}건)
- {list}

### Skipped 중복 ({count}건)
- {list}

### 위젯 커버리지
- 최소 요구: {4 (C1/C2) | 3 (C3)}
- 실제: {count}
- 달성: {✅ | ⚠️}
```

Clean cycle(이슈 0, drift 없음)은 축하 메시지 + "엣지 케이스 더 깊게" 힌트.

## 13. Fix 모드 — 7 스텝

### 13.1 Prerequisites

- Run 모드와 공통 (섹션 12.2)
- 추가: 반드시 main 기준 feature branch에서 실행 (memory 규칙)

### 13.2 스텝

**Step 1 — Open 이슈 나열**:

```bash
gh issue list --label dogfood --state open --json number,title,labels \
  -q '.[] | "\(.number)\t\(.title)\t\([.labels[].name] | join(","))"'
```

**Step 2 — 우선순위 정렬 & 분할 표시**:

```
## 🚀 Widget Gap Fast-track
| # | 이슈 | cycle |

## 기타 Open Issues (bug > dx > feature > docs)
| # | 카테고리 | 이슈 |

## Tuner Drift
| # | 드리프트 종류 |

## Upstream (GitHub Issue 없음)
- docs/upstream/ 에서 수동 추적
```

사용자에게 번호 선택 요청. 추천: fast-track 최상단 첫 번째.

**Step 3 — 이슈 상세 로드 & 브랜치 생성**:

```bash
gh issue view {N} --json body,title,labels
```

브랜치명:
- `fix/dogfood-{N}-{slug}` (버그·dx·docs)
- `feat/dogfood-{N}-pixel-{widget}` (widget-gap)
- `fix/tuner-drift-{N}` (tuner)

Main에서 분기. spec/plan이 필요한 경우 이 브랜치에 먼저 작성 후 구현 (memory 규칙).

**Step 4 — 구현**:

- widget-gap: 섹션 9.2 체크리스트 강제. `superpowers:writing-plans`로 세부 계획 뽑고 TDD로 진행
- bug: 재현 테스트 선행(Red) → 수정(Green) → 필요 시 golden 갱신
- dx: API 개선 시 breaking 판단 → deprecate 우회 or major bump 표시
- docs: README/Gallery/CHANGELOG 갱신
- tuner drift: 섹션 11.3 네이밍 컨벤션 준수

**Step 5 — 검증 (QA 게이트)**:

```bash
fvm flutter analyze
fvm flutter test --exclude-tags screenshot
# 필요 시:
fvm flutter test --update-goldens  # golden 의도 변경만
dart run tool/check_tuner_coverage.dart  # tuner 이슈 재확인
```

실패 시 수정까지 반복. 우회 금지 (`--no-verify` 등 불허).

**Step 6 — 커밋 & PR**:

- 커밋 저자: `BottlePumpkin <p4569zz@gmail.com>`, Claude 언급 없음 (memory 규칙)
- 메시지 컨벤션: `fix: resolve {issue}` / `feat: add Pixel{Name}` / `docs: improve {section}` / `chore: tuner coverage cycle#{N}`
- PR 본문:
  ```markdown
  Closes #{issue_N}

  ## 변경사항
  - ...

  ## 검증
  - [x] flutter analyze
  - [x] flutter test --exclude-tags screenshot
  - [x] (widget-gap만) 섹션 9.2 체크리스트 완료

  ## 스크린샷
  (시각 변경이면)
  ```
- `gh pr create --title "..." --body "..."`

**Step 7 — 이슈 링크 & 정리**:

```bash
gh issue comment {N} --body "Fix submitted in PR #{PR_N}"
```

머지·배포는 사용자 판단.

## 14. 스킬 파일 레이아웃

```
.claude/skills/dogfood/
├── SKILL.md                    # 엔트리 포인트. 이 설계의 12~13 섹션을 실행 지침으로 담음
├── personas.md                 # 섹션 3
├── topics.md                   # 섹션 5 (주제 풀, 랜덤 선택 로직)
├── issue-templates/
│   ├── bug.md
│   ├── dx.md
│   ├── feature.md
│   ├── widget-gap.md
│   ├── docs.md
│   └── tuner-drift.md
└── upstream-template.md        # 섹션 10
```

긴 템플릿은 별도 파일로 분리해 SKILL.md 토큰 최적화.

## 15. 보조 산출물

### 15.1 신규 파일

- `.claude/skills/dogfood/` 트리 (섹션 14)
- `tool/check_tuner_coverage.dart` (섹션 11)
- `docs/upstream/README.md` (빈 스켈레톤)

### 15.2 수정 파일

- `.gitignore` — `dogfood_cycle_*/` 추가
- `README.md` — 섹션 8.4 외부 사용자 필터 안내

### 15.3 GitHub 설정

- 라벨 생성 (섹션 8.3) — 스킬 prereqs가 idempotent 실행

## 16. 성공 기준

- `/dogfood run`을 실행하면 사이클이 처음부터 끝까지 중단 없이 완주
- 발견된 페르소나 이슈 7개 이하가 라벨과 template에 맞춰 파일링
- Tuner drift 집계 이슈는 사이클당 0 또는 1개, 재발 시 comment 방식
- Upstream 이슈는 GitHub에 파일링되지 않고 `docs/upstream/` 파일로만 격리
- `/dogfood fix`가 open 이슈를 widget-gap 최상단으로 정렬해 표시
- Widget-gap 구현은 섹션 9.2의 8개 체크리스트를 전부 통과한 PR로 머지

## 17. 범위 밖

- Run 모드에서 자동 스크린샷 캡처 (수동 첨부로 시작, 필요 시 `integration_test` 기반 자동화 별도 항목)
- `/dogfood widget` 전용 서브커맨드 (widget-gap 라벨로 충분, 복잡도 증가 회피)
- 외부 사용자 이슈 전용 트래커 분리 (저장소가 성장하면 재검토)
- `PixelText`, `PixelButton` 등 `PixelShapeStyle` 외 위젯의 tuner 커버리지 (tuner 자체가 확장되면 스크립트 targetTypes 확장)

## 18. 연관 문서

- rfw_gen dogfood 스킬 (참조 원본): `BottlePumpkin/rfw_gen/.claude/skills/dogfood/SKILL.md`
- pixel_ui ROADMAP: `docs/ROADMAP.md` (F 항목 Tuner 고도화와 연계)
- pixel_ui CLAUDE.md: 배포 리듬, 파일 무결성 규칙, 잠재 함정
