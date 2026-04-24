# PixelGrid — Tile-based Layout Widget

- 작성일: 2026-04-24
- 브랜치: `feat/dogfood-36-pixel-grid`
- 닫는 이슈: [#36](https://github.com/BottlePumpkin/pixel_ui/issues/36) (widget-gap fast-track)
- 버전 임팩트: `0.4.1 → 0.5.0` (minor bump, 신규 public widget 추가)

## 1. Overview & Goals

`PixelGrid<T>` — 타일 기반 레이아웃을 위한 공개 widget. 미니맵·인벤토리·월드맵·도감처럼 **동질 작은 셀의 2D 배열**을 렌더·인터랙션하는 공통 수요를 단일 위젯으로 흡수한다. dogfood cycle #2 (로그라이크 미니맵, C3 페르소나)에서 발굴한 widget-gap.

### Scope
- `PixelShapePainter` 위에 구축된 composite widget.
- 위치: 신규 `lib/src/pixel_grid.dart`, `lib/pixel_ui.dart`에서 export.
- 의존성: `flutter/widgets`, `flutter/material` (`Draggable`/`DragTarget` 사용). 외부 신규 의존성 없음.

### 비목표 (v1)
- 타일 간 transition/애니메이션
- viewport virtualization (무한 스크롤, lazy tile building)
- non-rectangular grid (hex, offset, isometric)
- gamepad 입력
- drag feedback 커스터마이즈 고급 제어 (v1은 고정 `Opacity(0.7)` 복제)

## 2. Public API

```dart
class PixelGrid<T> extends StatefulWidget {
  /// 정적 2D 데이터 생성자. `data[y][x]` 가 `null` 이면 빈 칸.
  const PixelGrid.fromList({
    required List<List<T?>> data,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.styleFor,
    this.emptyStyle,
    this.dragDataFor,
    this.onTileTap,
    this.onTileActivate,
    this.onTileAccept,
    this.isTileEnabled,
    this.autofocus = false,
    this.focusNode,
    this.gap = 0,
    super.key,
  });

  /// 동적 빌더 생성자. 큰 맵 / procedural generation.
  const PixelGrid.builder({
    required this.rows,
    required this.cols,
    required T? Function(int x, int y) tileAt,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.styleFor,
    this.emptyStyle,
    this.dragDataFor,
    this.onTileTap,
    this.onTileActivate,
    this.onTileAccept,
    this.isTileEnabled,
    this.autofocus = false,
    this.focusNode,
    this.gap = 0,
    super.key,
  });

  // Rendering
  final int tileLogicalWidth;       // 각 타일의 PixelShapePainter logical 폭 (정수)
  final int tileLogicalHeight;      // 각 타일의 PixelShapePainter logical 높이 (정수)
  final Size tileScreenSize;        // 각 타일의 rendered size
  final PixelShapeStyle Function(T data) styleFor;
  final PixelShapeStyle? emptyStyle;  // null 데이터용 스타일. null이면 빈 공간.
  final double gap;                 // 타일 간 간격 (logical pixels), 기본 0

  // Interaction
  final T? Function(int x, int y)? dragDataFor;   // null → 해당 타일 드래그 불가
  final void Function(int x, int y)? onTileTap;
  final void Function(int x, int y)? onTileActivate;  // Enter/Space
  final void Function((int, int) from, (int, int) to, T data)? onTileAccept;

  // Keyboard
  final bool Function(int x, int y)? isTileEnabled;   // arrow-key skip 대상
  final bool autofocus;
  final FocusNode? focusNode;

  // (fromList) private: derived from data
  // (builder) public: rows, cols, tileAt
}
```

### 설계 결정 맵핑
| 결정 | API 반영 |
|---|---|
| C (full interaction) | `onTileTap`, `onTileActivate`, `onTileAccept` |
| P2 (Draggable↔DragTarget) + T1 (generic `T`) | `dragDataFor: T?`, `onTileAccept: (from, to, T)` |
| K2 (grid-level focus + arrow-key navigation) | `onTileActivate`, `isTileEnabled`, `focusNode`, `autofocus` |
| D3 (fromList + builder) | 두 named constructor |
| O1 (naïve painter 독립 instance) | 내부에서 `CustomPaint(painter: PixelShapePainter(...))` 직접 나열, 캐시 없음 |
| T-B (tuner 분리) | 본 PR에 tuner 변경 없음. follow-up 이슈로 분리. |

## 3. Internal Architecture

단일 파일 `lib/src/pixel_grid.dart`. `.fromList` 생성자는 내부적으로 `.builder` 로 위임 (`tileAt: (x, y) => data[y][x]`) — 구현 중복 없음.

```
PixelGrid<T>  (StatefulWidget)
 └─ _PixelGridState<T>
     ├─ FocusNode (외부 주입 또는 internally created)
     ├─ (int, int) _focused                         // K2 선택 상태
     └─ build():
         Focus(focusNode, onKeyEvent: _handleKey) {
           Column(rows) {
             for y in 0..rows:
               Row(cols) {
                 for x in 0..cols: _Tile<T>(x, y, ...)
               }
           }
         }

_Tile<T>  (StatelessWidget)
 ├─ T? data = tileAt(x, y)
 ├─ PixelShapeStyle? style = data == null ? emptyStyle : styleFor(data)
 ├─ bool draggable = dragDataFor?.call(x, y) != null
 └─ build():
     GestureDetector(onTap: () => onTileTap?.call(x, y) + focus 이동) {
       DragTarget<_DragPayload<T>>(
         onAcceptWithDetails: (d) =>
           onTileAccept?.call(d.data.from, (x, y), d.data.payload),
         builder: (ctx, _, __) {
           draggable
             ? Draggable<_DragPayload<T>>(
                 data: (from: (x, y), payload: dragDataFor!(x, y) as T),
                 feedback: Opacity(opacity: 0.7, child: _TilePaint(style)),
                 child: _TilePaint(style, focused: _focused == (x, y)),
               )
             : _TilePaint(style, focused: _focused == (x, y))
         }
       )
     }

_TilePaint  (StatelessWidget)
 └─ Stack {
      CustomPaint(
        size: tileScreenSize,
        painter: PixelShapePainter(
          logicalWidth: tileLogicalWidth,
          logicalHeight: tileLogicalHeight,
          style: style,
        ),
      ),
      if (focused) _FocusOutline(size: tileScreenSize),  // 1px outline overlay
    }
```

### 핵심 분리 원칙
- `_Tile<T>` — 인터랙션 책임 (gesture, drag, drop)
- `_TilePaint` — 순수 렌더 책임 (stateless, 테스트하기 쉬움)
- `_PixelGridState<T>` — 좌표/focus 상태 보유

### `_DragPayload<T>`
internal record:

```dart
typedef _DragPayload<T> = ({(int, int) from, T payload});
```

source 좌표를 함께 실어 `onTileAccept(from, to, data)` 시그니처 충족.

## 4. Data Flow

### 4-a. 좌표 → 화면 위치
- 각 타일은 `SizedBox(size: tileScreenSize)` 내부에 `CustomPaint`.
- `gap > 0` 이면 `Row`/`Column`의 `spacing` 프로퍼티 사용 (Flutter 3.22+; pixel_ui는 `>=3.32.0`이라 지원).

### 4-b. Tap
```dart
GestureDetector(onTap: () {
  onTileTap?.call(x, y);
  _moveFocusTo((x, y));   // tap이 focus 이동도 트리거
})
```

### 4-c. Keyboard (K2)
```dart
KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
  if (event is! KeyDownEvent) return KeyEventResult.ignored;
  final (fx, fy) = _focused;
  switch (event.logicalKey) {
    case LogicalKeyboardKey.arrowUp:    _moveFocus(0, -1);
    case LogicalKeyboardKey.arrowDown:  _moveFocus(0,  1);
    case LogicalKeyboardKey.arrowLeft:  _moveFocus(-1, 0);
    case LogicalKeyboardKey.arrowRight: _moveFocus(1,  0);
    case LogicalKeyboardKey.enter:
    case LogicalKeyboardKey.space:
      final data = _tileAt(fx, fy);
      if (data != null) onTileActivate?.call(fx, fy);
    default: return KeyEventResult.ignored;
  }
  return KeyEventResult.handled;
}
```

- `_moveFocus(dx, dy)`: 다음 **enabled** 타일 skip-search. `isTileEnabled(x, y) == false`인 타일은 건너뜀. 경계에서 no-op (wrap-around 없음 — 예측 가능성 우선).
- focused 타일은 `_FocusOutline` 1px overlay — painter 수정 없음, 기존 `PixelShapeStyle` 보존.

### 4-d. Drag & Drop (P2)
- `dragDataFor(x, y)` non-null → 해당 타일은 `Draggable` 로 래핑.
- Drop: **모든 타일**이 `DragTarget<_DragPayload<T>>` 를 가진다. 거부 로직은 사용자 콜백에서 처리.
- `onTileAccept(from, to, payload)` 로 사용자가 swap/merge/reject 결정.
- Drag feedback: `_TilePaint` 복제 + `Opacity(0.7)`.

## 5. Edge cases & asserts

- `List<List<T?>>` rows 불균일 → `assert(data.every((row) => row.length == data[0].length))`
- `rows <= 0` / `cols <= 0` / `data.isEmpty` / `data[0].isEmpty` → assert. 0×0 그리드는 v1에서 방어적으로 차단.
- `tileLogicalWidth <= 0` / `tileLogicalHeight <= 0` → assert (painter가 어차피 assert하지만 조기 catch).
- `dragDataFor == null && onTileAccept != null` → assert ("drop target 없음; dragDataFor를 지정하세요")
- Focus wrap 안 함 (4-c). 경계 넘어가려 하면 no-op.
- `tileScreenSize` 와 logical dim의 aspect ratio 불일치 — painter는 수평 px 기준으로 계산 (`PixelShapePainter` 0.4.1 dartdoc 참조). 경고 대신 dartdoc에 "권장: 비율 일치" 명시.
- `data[y][x]` 가 `null` 이면서 `onTileActivate` 지정 — null 타일에서 Enter/Space 눌려도 콜백 호출 안 함 (빈 칸은 "활성화 가능한 타일"이 아님). §4-c에 명시.
- 데이터 인덱싱 규약: `data[y][x]` (`List<List<T?>>` 에서 외부 리스트 = rows, 내부 리스트 = cols). dartdoc 및 README 명시.

## 6. Testing

### 6-a. `test/pixel_grid_test.dart` — 단위/위젯 테스트 ≥ 8 케이스
1. `.fromList` 5×3 그리드 렌더 → `CustomPaint` 15개 존재
2. `.builder` 로 동일 패턴 커버
3. `data[y][x] == null` + `emptyStyle: null` → 자리 비어있음 (투명)
4. `onTileTap` 콜백 호출 검증 (좌표별 ValueKey 사용해서 `tester.tap`)
5. 방향키 4방향 이동 + 경계에서 no-op
6. `isTileEnabled: (x, y) => (x + y).isEven` 로 skip-search 검증
7. Enter/Space 로 `onTileActivate` 호출
8. Drag + Drop → `onTileAccept`에 올바른 `(from, to, T)` 전달 (`tester.drag`)

### 6-b. `test/pixel_grid_golden_test.dart` — `@Tags(['golden'])`
1. 3×3 floor/wall/fog 미니맵
2. 2×2 인벤토리 with focused outline

### 6-c. 기존 suite 무회귀
`fvm flutter test --exclude-tags screenshot` — 145 → 155+ 테스트, 전부 통과.

## 7. README + Gallery + example

- **README `## Usage`**: 새 서브섹션 "Tile grids" 추가. 2D 인벤토리 예제 + drag 스왑 한 조각.
- **README Gallery**: `doc/screenshots/06_pixel_grid.png` 추가. `test/screenshots/scenes/pixel_grid_scene.dart` 작성 → `tool/generate_screenshots.dart`로 생성.
- **`example/lib/main.dart`** `_ShowcaseScreen`에 `_PixelGridDemo` 섹션 추가 — 5×5 인벤토리 + drag 스왑 + 방향키 데모.
- **CHANGELOG 0.5.0 `### Added`**: `PixelGrid<T>` 엔트리.
- **pubspec screenshots**: 새 스크린샷 등록 (`description: "Tile grid with drag & focus"`).

## 8. widget-gap 8-항목 체크리스트 매핑

| # | 항목 | 커버 |
|---|---|---|
| 1 | API 설계 기록 | 본 spec |
| 2 | 공개 API 노출 | `lib/pixel_ui.dart` export |
| 3 | 단위 테스트 | §6-a |
| 4 | 골든 테스트 | §6-b |
| 5 | README Gallery | §7 |
| 6 | CHANGELOG | 0.5.0 "Added" (§7) |
| 7 | example 쇼케이스 | `example/lib/main.dart` (§7) |
| 8 | tuner 대상 판단 | **분리 (T-B)** — follow-up 이슈로 추적 |

## 9. Follow-ups (본 PR 밖)

- tuner에 `PixelGrid` preview + controls (신규 이슈)
- viewport virtualization / 무한 스크롤
- non-rectangular (hex / offset / isometric) grids
- drag feedback 커스터마이즈 (`feedbackBuilder`)
- performance 측정 → O2 (style별 painter 캐시) 전환 여부
- gamepad 입력

## 10. 마일스톤

1. **M1 — Core render**: `.fromList`/`.builder`, `_Tile`, `_TilePaint`. 기본 렌더 테스트.
2. **M2 — Tap + Focus (K2)**: Focus/Key 이벤트, `onTileTap`, `onTileActivate`, `isTileEnabled`. 키보드 테스트.
3. **M3 — Drag & Drop (P2+T1)**: `Draggable`/`DragTarget`, `onTileAccept`. drag 테스트.
4. **M4 — Gallery/Docs/Example**: 골든, 쇼케이스, README, CHANGELOG, screenshots 생성.
5. **M5 — Release**: 0.5.0 tag push → publish.yml → pub.dev.
