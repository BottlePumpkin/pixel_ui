# Dogfood App Topics

Run 시 선택 규칙:
1. 친화 페르소나와 매칭되는 주제 우선
2. 과거 이슈 body의 `주제:` 파싱해 중복 회피
3. 친화 주제가 전부 소진되면 비친화 주제로 확장

## 주제 풀 (15개)

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

## 위젯 커버리지 최소 요구

- **C1·C2**: 공개 API 최소 4개 사용 (`PixelBox` / `PixelButton` / `PixelText` / `PixelShapeStyle` 조합)
- **C3**: 엣지 케이스 최소 3개 시도 (비대칭 corners / 네거티브 shadow offset / 극단 logicalWidth)

## 권장

- 레이아웃(스크롤/그리드/열) + 인터랙션(터치/입력) 둘 다 포함
- 주제가 "없는 위젯"을 암시하면 반드시 Flutter 기본 위젯으로 fallback 구현 시도 → 이 고통이 `widget-gap` 이슈의 증거