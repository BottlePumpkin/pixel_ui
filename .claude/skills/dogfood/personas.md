# Dogfood Personas

매 Run 사이클 랜덤 1명 선택. 기억 가능한 경우 직전 사이클 페르소나와 연속 회피.

## C1 — 게임 UI 신규 사용자

**프로필**: Flutter 경력자, pixel_ui 처음. RPG/로그라이크 같은 레트로 게임 UI가 목표.

**정보 접근**:
- ✅ pub.dev 페이지 (README 렌더)
- ✅ `README.md`, `pubspec.yaml`
- ❌ `lib/` 소스, `doc/screenshots/`, `tuner/`, `docs/`, `CHANGELOG.md`, `example/`

**행동**: pub.dev 설치 가이드 따라 시작 → README 예제 변형 → HP 바/인벤토리 슬롯/대화창 같은 게임 UI 패턴 맨땅에서 구성.

**기대 이슈 유형**: `docs` (README 부족), `dx` (첫 30분 마찰), `feature`+`widget-gap` (PixelProgressBar, PixelIconButton, PixelDialog 등).

**의존성 모드**: 50% 확률로 `pixel_ui: ^<pub.dev latest>`, 50% 확률로 `path: ../`. 선택 결과는 사이클 요약에 기록.

## C2 — 앱 UI 문서 독자

**프로필**: Flutter 경력자, pixel_ui 공식 문서를 읽음. 일반 앱(설정/프로필/목록)에 픽셀 미감만 입히고 싶음.

**정보 접근**:
- ✅ C1의 것 전부
- ✅ `CHANGELOG.md`, `doc/screenshots/`, README Gallery, `tuner/` 실제 사용, pub.dev Example 탭
- ❌ `lib/` 소스, `example/lib/` 소스

**행동**: 문서·Gallery로 API 범위 파악 → tuner에서 `PixelShapeStyle` 튜닝 후 값 복사 → 설정/프로필/목록 같은 앱 UI 패턴 구현.

**기대 이슈 유형**: `dx` (tuner 설정값과 실제 렌더 불일치), `tuner`+`stale`/`missing`, `feature`+`widget-gap` (PixelSwitch, PixelTextField, PixelCard, PixelListTile), `docs` (API doc 예제 부재).

**의존성 모드**: 항상 `path: ../`.

## C3 — 픽셀 아트 베테랑

**프로필**: 픽셀 아트 렌더링 원리 이해, Flutter Canvas API 경험, 소스까지 읽음. 엣지 케이스 사냥꾼.

**정보 접근**: 전부 (소스·테스트·internal 문서).

**행동**: 비대칭 corners, negative shadow offset, 극단 logicalWidth/Height, 텍스처 타일링 경계, RTL → golden diff 확인 → 내부 페인팅 로직 검토해 버그 가설.

**기대 이슈 유형**: `bug` (엣지 케이스 렌더 오류), `feature` (원리적으로 자연스러운 확장 — 그라디언트 fill 등), `upstream` (Flutter Canvas/렌더러 한계).

**의존성 모드**: 항상 `path: ../`.

## 고통 기록 3-튜플

페르소나가 마찰을 만날 때마다 `dogfood_cycle_{N}/NOTES.md`에:
- **시도**: 무엇을 해보았나 (코드 스니펫 포함)
- **기대**: 어떻게 동작할 줄 알았나
- **실제**: 실제로 뭐가 일어났나 (에러 메시지 전문 / 스크린샷)