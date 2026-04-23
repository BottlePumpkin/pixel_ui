Title: [dogfood/tuner] Coverage drift (cycle #{N})
Labels: dogfood,dx,tuner

## Drift 감지 (cycle #{N})

`tool/check_tuner_coverage.dart` 자동 감지 결과.

### Missing controls ({count})
{체크리스트 — 공개 필드인데 tuner 컨트롤이 없는 항목}
- [ ] {FieldName}

### Orphan controls ({count})
{체크리스트 — 컨트롤 파일은 있으나 대응 공개 필드 없음}
- [ ] {controls/xxx.dart}

### Broken controls ({count})
{체크리스트 — 파일은 있으나 home_page.dart 등에 import 안 됨}
- [ ] {controls/yyy.dart}

## 처리 가이드
- 누락은 `tuner/lib/src/controls/`에 컨트롤 추가 (composite도 OK)
- 고아는 삭제 또는 매핑 회복
- 같은 drift가 3사이클 연속 open이면 `priority-high` 라벨 자동 추가됨

## 영향
- 파일: `tuner/lib/src/controls/*`, `tuner/lib/src/home_page.dart`
