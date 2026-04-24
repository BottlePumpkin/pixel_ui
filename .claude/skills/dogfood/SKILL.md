---
name: dogfood
description: Simulate a first-time pixel_ui user to discover DX issues, missing widgets, and bugs. Use /dogfood run to start a collection cycle, /dogfood fix to resolve filed issues. Triggers when user mentions dogfooding, DX testing, user simulation, widget gap, or wants to find usability issues in pixel_ui.
user_invocable: true
---

# Dogfood Skill (pixel_ui)

첫 사용자 페르소나를 매 사이클 시뮬레이션해 pixel_ui의 마찰·없는 위젯·버그를 발굴하고 GitHub Issue로 기록한다. 설계 전체는 `docs/superpowers/specs/2026-04-23-dogfood-skill-design.md` 참조.

## Argument Parsing

- `/dogfood run` → Run Mode (Section: Run Mode)
- `/dogfood run --keep` → Run Mode, 사이클 디렉토리 삭제 스킵
- `/dogfood fix` → Fix Mode (Section: Fix Mode)
- `/dogfood` → `Usage: /dogfood run [--keep] | /dogfood fix` 출력 후 중단

## Prerequisites (양쪽 모드 공통)

1. **git identity 검증** — `.claude/settings.json` SessionStart hook 결과 재확인. 불일치 시 경고 후 중단.
2. **gh auth** — `gh auth status`. 실패 시 `! gh auth login` 안내 후 중단.
3. **GitHub 라벨 생성** — 아래 스크립트 idempotent 실행:

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

4. **.gitignore 체크** — `dogfood_cycle_*/` 패턴 없으면 추가 후 커밋.
5. **브랜치 확인** — Fix 모드는 반드시 main에서 분기한 feature branch에서 실행. Run 모드는 제약 없음.

## Run Mode

페르소나·주제·사이클 디렉토리는 `personas.md`, `topics.md` 참조.

### Step 1: 이전 사이클 정리
`rm -rf dogfood_cycle_*/` (단 `--keep` 플래그면 스킵)

### Step 2: 사이클 번호 결정
`gh issue list --label dogfood --state all --limit 200 --json body -q '.[].body'` → body에서 `사이클: #N` 파싱 → max+1. 이슈 없으면 #1.

### Step 3: 페르소나 랜덤 선택
`personas.md`의 C1/C2/C3 중 1명. 기억 가능한 경우 직전 사이클과 연속 회피. C1이면 50/50으로 pub.dev vs path 의존성 모드 분기.

### Step 4: 주제 선택
`topics.md`의 풀 중 친화 페르소나 매칭 우선, 과거 이슈 body의 `주제:` 파싱해 중복 회피.

### Step 5: 사이클 디렉토리 생성
```bash
flutter create dogfood_cycle_{N} --project-name dogfood_cycle_{N}
```
pubspec에 의존성 추가 (페르소나/모드에 따라 `path: ../` 또는 `pixel_ui: ^<pub.dev latest>`).
`cd dogfood_cycle_{N} && flutter pub get`. 실패 시 에러 자체를 이슈로 파일링하고 사이클 중단.

### Step 6: 페르소나 시뮬레이션 개발
정보 접근 제약을 엄격히 지킨다 (personas.md 세칙). 최소 커버리지:
- C1·C2: 공개 API 4개 이상
- C3: 엣지 케이스 3개 이상
- 레이아웃 + 인터랙션 둘 다 포함

마찰 만날 때마다 `dogfood_cycle_{N}/NOTES.md`에 3-튜플로 기록:
- **시도**: 무엇을 해보았나
- **기대**: 어떻게 동작할 줄 알았나
- **실제**: 실제로 뭐가 일어났나

시각 버그는 스크린샷(수동 캡처 또는 ASCII diagram)을 NOTES에 첨부.

### Step 7: Tuner 커버리지 드리프트 체크
프로젝트 루트에서:
```bash
fvm dart run tool/check_tuner_coverage.dart --json > /tmp/tuner_drift_{N}.json
```
드리프트 있으면 Step 10c에서 집계 이슈 1개 준비(quota 밖).

### Step 8: 이슈 분류 · 우선순위
페르소나 발견 이슈를 `issue-templates/`의 카테고리로 분류:
`bug > dx > feature(widget-gap 우선) > docs`. Max 7개 quota. 초과는 summary의 "deferred"로 기록.

### Step 9: 중복 검사
```bash
gh issue list --label dogfood --state open --json title,number,body
```
제목·키워드 유사도 비교. 명백 중복 스킵 + summary의 "중복 스킵" 섹션 기록.

### Step 10: Upstream 격리 & GitHub Issue 파일링

**10a. Upstream**: `upstream` 분류 이슈는 `docs/upstream/{slug}.md` 생성(`upstream-template.md` 기반) + `docs/upstream/README.md`의 "수집됨" 섹션에 한 줄 링크 추가. GitHub Issue는 파일링하지 않음.

**10b. 페르소나 이슈**: `issue-templates/{category}.md`의 body 템플릿으로 `gh issue create`. 라벨 조합:
- 기본: `dogfood,{category}`
- widget-gap이면 `dogfood,feature,widget-gap`
- tuner 이슈면 `dogfood,{category},tuner,{stale|missing}`

**10c. Tuner drift 집계**: `issue-templates/tuner-drift.md` 템플릿 사용. 기존 open drift 이슈 있으면 신규 생성 대신 `gh issue comment`로 "cycle #N에서도 감지됨" 추가. 동일 drift가 3사이클 연속 open이면 `priority-high` 라벨 자동 추가.

### Step 11: 사이클 요약 출력

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

Clean cycle(이슈 0, drift 없음)은 축하 메시지 + "다음 사이클엔 엣지 케이스 더 깊게" 힌트.

## Fix Mode

### Step 1: Open 이슈 나열
```bash
gh issue list --label dogfood --state open --json number,title,labels \
  -q '.[] | "\(.number)\t\(.title)\t\([.labels[].name] | join(","))"'
```

### Step 2: 우선순위 정렬 & 분할 표시
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

### Step 3: 이슈 상세 로드 & 브랜치 생성
```bash
gh issue view {N} --json body,title,labels
```
브랜치명 규칙:
- `fix/dogfood-{N}-{slug}` — bug·dx·docs
- `feat/dogfood-{N}-pixel-{widget}` — widget-gap
- `fix/tuner-drift-{N}` — tuner

반드시 main에서 분기. spec/plan 필요 시 브랜치에 먼저 작성 후 구현.

### Step 4: 구현
- **widget-gap**: 8-항목 체크리스트(아래) 전부 통과해야 머지. `superpowers:writing-plans`로 세부 계획 뽑고 TDD로 진행.
- **bug**: 재현 테스트 선행(Red) → 수정(Green) → 필요 시 골든 갱신.
- **dx**: API 개선이 breaking인지 판단 → deprecate 우회 또는 major bump 표시.
- **docs**: README/Gallery/CHANGELOG 갱신.
- **tuner drift**: 스펙의 네이밍 컨벤션 권장안 준수(composite OK), 컨트롤 추가/정리 후 `dart run tool/check_tuner_coverage.dart` 재확인.

#### Widget-gap 구현 체크리스트 (PR 머지 조건)
```markdown
- [ ] API 설계 기록: `docs/widgets/pixel_{name}.md` 또는 PR description에 시그니처·사용 예제 작성
- [ ] 공개 API 노출: `lib/pixel_ui.dart` export 추가
- [ ] 단위 테스트: `test/pixel_{name}_test.dart`
- [ ] 골든 테스트: 최소 1개 시각 회귀 방지
- [ ] README Gallery 갱신: 새 위젯 스크린샷 + 코드 예제
- [ ] CHANGELOG 엔트리: "Added" 섹션 추가
- [ ] example 쇼케이스 반영: 필요 시 `example/lib/`에 데모 추가
- [ ] tuner 대상 여부 판단: 시각 파라미터 있으면 tuner 컨트롤 추가 (별도 이슈 분리 가능)
```

### Step 5: 검증 (QA 게이트)
```bash
fvm flutter analyze
fvm flutter test --exclude-tags screenshot
```
필요 시:
```bash
fvm flutter test --update-goldens              # golden 의도 변경만
fvm dart run tool/check_tuner_coverage.dart    # tuner 이슈 재확인
```
실패 시 수정까지 반복. `--no-verify`류 우회 금지.

### Step 6: 커밋 & PR
- 커밋 저자: `BottlePumpkin <p4569zz@gmail.com>`, Claude 언급 없음.
- 메시지 컨벤션: `fix: resolve {issue}` / `feat: add Pixel{Name}` / `docs: improve {section}` / `chore: tuner coverage cycle#{N}`.
- PR 본문:
```markdown
Closes #{issue_N}

## 변경사항
- ...

## 검증
- [x] flutter analyze
- [x] flutter test --exclude-tags screenshot
- [x] (widget-gap만) 위 8-항목 체크리스트 완료

## 스크린샷
(시각 변경이면)
```
```bash
gh pr create --title "..." --body "..."
```

### Step 7: 이슈 링크 & 정리
```bash
gh issue comment {N} --body "Fix submitted in PR #{PR_N}"
```
머지·배포는 사용자 판단.