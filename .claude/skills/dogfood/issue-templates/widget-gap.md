Title: [dogfood/widget-gap] PixelXxx — {short purpose}
Labels: dogfood,feature,widget-gap

## 발견 컨텍스트
- 사이클: #{N}
- 주제: {topic}
- 페르소나: {C1/C2/C3 name}

## 요청 위젯
**이름 후보**: PixelXxx

**용도**: {what it's for, what problem it solves}

## 현재 fallback 시도
{Flutter 기본 위젯으로 우회한 코드와 그 한계}

## 기대 API 스케치
```dart
// Rough sketch; finalized during /dogfood fix
PixelXxx(
  // ...
)
```

## 구현 체크리스트 (Fix 시 PR 머지 조건)
- [ ] API 설계 기록: `docs/widgets/pixel_{name}.md` 또는 PR description
- [ ] 공개 API 노출: `lib/pixel_ui.dart` export 추가
- [ ] 단위 테스트: `test/pixel_{name}_test.dart`
- [ ] 골든 테스트: 최소 1개 시각 회귀 방지
- [ ] README Gallery 갱신: 스크린샷 + 코드 예제
- [ ] CHANGELOG 엔트리: "Added" 섹션
- [ ] example 쇼케이스 반영
- [ ] tuner 대상 여부 판단

## 참고 (유사 위젯)
{예: Material's Switch, Cupertino 쪽 패턴 등 — 순전히 참고용}
