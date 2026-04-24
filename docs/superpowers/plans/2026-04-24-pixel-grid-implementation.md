# PixelGrid Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement `PixelGrid<T>` — a tile-based layout widget with tap, keyboard focus (arrow-key navigation + Enter/Space activate), and drag-and-drop via `Draggable<T>`/`DragTarget<T>`. Closes dogfood issue #36. Ships as v0.5.0.

**Architecture:** Single Stateful widget backed by `PixelShapePainter`. Internal split: `_PixelGridState<T>` (focus state + key handling) → `_Tile<T>` (gesture/drag wrapper) → `_TilePaint` (stateless rendering). `.fromList` constructor delegates to `.builder` so only one implementation path exists. See `docs/superpowers/specs/2026-04-24-pixel-grid-design.md` for full design rationale.

**Tech Stack:** Flutter `>=3.32.0`, Dart `^3.8.0`. Material (`Draggable`, `DragTarget`), Services (`LogicalKeyboardKey`, `FocusNode`). No new external dependencies.

---

## File Structure

Files created or modified by this plan:

| Path | Responsibility | Size |
|---|---|---|
| `lib/src/pixel_grid.dart` | `PixelGrid<T>` widget + `_PixelGridState` + `_Tile` + `_TilePaint` + `_FocusOutline` | new, ~350 LOC |
| `lib/pixel_ui.dart` | add `export 'src/pixel_grid.dart';` | modify |
| `test/pixel_grid_test.dart` | widget tests (render, tap, keyboard, drag) | new, ~300 LOC |
| `test/pixel_grid_golden_test.dart` | golden minimap + inventory scenes | new, ~80 LOC |
| `test/goldens/pixel_grid/*.png` | golden baselines | new (2 files) |
| `test/screenshots/scenes/pixel_grid_scene.dart` | pub.dev screenshot scene | new |
| `test/screenshots/screenshots_test.dart` | register new scene | modify |
| `doc/screenshots/06_pixel_grid.png` | pub.dev screenshot (copied via `tool/update_screenshots.sh`) | new |
| `example/lib/main.dart` | `_PixelGridDemo` section | modify |
| `README.md` | Usage "Tile grids" subsection + Gallery cell | modify |
| `CHANGELOG.md` | `## 0.5.0` entry | modify |
| `pubspec.yaml` | version bump + screenshots registration | modify |
| `tool/update_screenshots.sh` | add `06_pixel_grid` to expected list | modify |

---

## M1 — Core Render

### Task 1: Skeleton widget class + builder/fromList constructors

**Files:**
- Create: `lib/src/pixel_grid.dart`

- [ ] **Step 1: Create the file with public API skeleton (compiles, no logic yet)**

```dart
// lib/src/pixel_grid.dart
import 'package:flutter/material.dart';

import 'package:pixel_ui/src/pixel_shape_painter.dart';
import 'package:pixel_ui/src/pixel_style.dart';

/// Tile-based layout widget backed by [PixelShapePainter].
///
/// Use [PixelGrid.fromList] for static 2D data, or [PixelGrid.builder] for
/// dynamic / procedural tiles. Data indexing convention: `data[y][x]` —
/// outer list = rows, inner list = columns. `null` data = empty slot.
class PixelGrid<T> extends StatefulWidget {
  /// Static 2D data. `data[y][x] == null` leaves the slot empty.
  PixelGrid.fromList({
    super.key,
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
  })  : assert(data.isNotEmpty, 'PixelGrid.fromList: data must not be empty'),
        assert(data[0].isNotEmpty,
            'PixelGrid.fromList: data rows must not be empty'),
        assert(data.every((row) => row.length == data[0].length),
            'PixelGrid.fromList: all rows must have the same length'),
        assert(tileLogicalWidth > 0, 'tileLogicalWidth must be positive'),
        assert(tileLogicalHeight > 0, 'tileLogicalHeight must be positive'),
        assert(dragDataFor != null || onTileAccept == null,
            'onTileAccept requires dragDataFor so tiles can be drag sources'),
        rows = data.length,
        cols = data[0].length,
        tileAt = ((int x, int y) => data[y][x]);

  /// Procedural builder. [rows] × [cols]; [tileAt] returns the data at a
  /// given cell (`null` = empty slot).
  PixelGrid.builder({
    super.key,
    required this.rows,
    required this.cols,
    required this.tileAt,
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
  })  : assert(rows > 0, 'rows must be positive'),
        assert(cols > 0, 'cols must be positive'),
        assert(tileLogicalWidth > 0, 'tileLogicalWidth must be positive'),
        assert(tileLogicalHeight > 0, 'tileLogicalHeight must be positive'),
        assert(dragDataFor != null || onTileAccept == null,
            'onTileAccept requires dragDataFor so tiles can be drag sources');

  final int rows;
  final int cols;
  final T? Function(int x, int y) tileAt;

  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;
  final double gap;

  final PixelShapeStyle Function(T data) styleFor;
  final PixelShapeStyle? emptyStyle;

  final T? Function(int x, int y)? dragDataFor;
  final void Function(int x, int y)? onTileTap;
  final void Function(int x, int y)? onTileActivate;
  final void Function((int, int) from, (int, int) to, T data)? onTileAccept;

  final bool Function(int x, int y)? isTileEnabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<PixelGrid<T>> createState() => _PixelGridState<T>();
}

class _PixelGridState<T> extends State<PixelGrid<T>> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // replaced in Task 2
  }
}
```

- [ ] **Step 2: Verify the file compiles by running analyze**

Run: `fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/pixel_grid.dart
git commit -m "feat: scaffold PixelGrid<T> skeleton (#36)"
```

---

### Task 2: Render rows × cols of `_TilePaint`

**Files:**
- Modify: `lib/src/pixel_grid.dart`
- Create: `test/pixel_grid_test.dart`

- [ ] **Step 1: Write failing widget test**

```dart
// test/pixel_grid_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _wall = _Kind.wall;
const _floor = _Kind.floor;

enum _Kind { wall, floor }

PixelShapeStyle _styleFor(_Kind k) => const PixelShapeStyle(
      corners: PixelCorners.sharp,
      fillColor: Color(0xFF888888),
    );

void main() {
  testWidgets('fromList renders rows × cols CustomPaint widgets',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelGrid<_Kind>.fromList(
              data: const [
                [_wall, _floor, _floor],
                [_floor, _wall, _floor],
                [_floor, _floor, _wall],
                [_wall, _floor, _wall],
                [_floor, _wall, _floor],
              ],
              tileLogicalWidth: 4,
              tileLogicalHeight: 4,
              tileScreenSize: const Size(16, 16),
              styleFor: _styleFor,
            ),
          ),
        ),
      ),
    );

    // 5 rows × 3 cols = 15 tiles.
    expect(
      find.byType(CustomPaint).evaluate().where((e) {
        final painter = (e.widget as CustomPaint).painter;
        return painter is PixelShapePainter;
      }).length,
      15,
    );
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: FAIL (0 CustomPaint with PixelShapePainter, because state returns SizedBox.shrink).

- [ ] **Step 3: Implement rendering in `_PixelGridState.build` and add `_TilePaint`**

Replace the entire `_PixelGridState` class and append `_TilePaint` in `lib/src/pixel_grid.dart`:

```dart
class _PixelGridState<T> extends State<PixelGrid<T>> {
  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int y = 0; y < widget.rows; y++) {
      final tiles = <Widget>[];
      for (int x = 0; x < widget.cols; x++) {
        tiles.add(_tileFor(x, y));
      }
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        spacing: widget.gap,
        children: tiles,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.gap,
      children: rows,
    );
  }

  Widget _tileFor(int x, int y) {
    final data = widget.tileAt(x, y);
    final style = data == null ? widget.emptyStyle : widget.styleFor(data);
    return _TilePaint(
      key: ValueKey<(int, int)>((x, y)),
      style: style,
      tileLogicalWidth: widget.tileLogicalWidth,
      tileLogicalHeight: widget.tileLogicalHeight,
      tileScreenSize: widget.tileScreenSize,
    );
  }
}

class _TilePaint extends StatelessWidget {
  const _TilePaint({
    super.key,
    required this.style,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
  });

  final PixelShapeStyle? style;
  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;

  @override
  Widget build(BuildContext context) {
    final style = this.style;
    if (style == null) {
      return SizedBox(width: tileScreenSize.width, height: tileScreenSize.height);
    }
    return CustomPaint(
      size: tileScreenSize,
      painter: PixelShapePainter(
        logicalWidth: tileLogicalWidth,
        logicalHeight: tileLogicalHeight,
        style: style,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test — verify it passes**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/pixel_grid.dart test/pixel_grid_test.dart
git commit -m "feat: PixelGrid renders rows × cols tiles"
```

---

### Task 3: Empty tile rendering

**Files:**
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Write failing test**

Append inside `void main()`:

```dart
  testWidgets('null data + no emptyStyle renders empty SizedBox',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.fromList(
            data: const [
              [_Kind.wall, null],
              [null, _Kind.wall],
            ],
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
          ),
        ),
      ),
    );

    final paintsWithPainter = find.byType(CustomPaint).evaluate().where((e) {
      return (e.widget as CustomPaint).painter is PixelShapePainter;
    }).length;
    // 2 non-null tiles only (out of 4 slots).
    expect(paintsWithPainter, 2);
  });

  testWidgets('null data + emptyStyle renders emptyStyle for null slots',
      (tester) async {
    const emptyStyle = PixelShapeStyle(
      corners: PixelCorners.sharp,
      fillColor: Color(0xFF222222),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.fromList(
            data: const [
              [_Kind.wall, null],
              [null, _Kind.wall],
            ],
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            emptyStyle: emptyStyle,
          ),
        ),
      ),
    );

    // All 4 slots painted now.
    final paintsWithPainter = find.byType(CustomPaint).evaluate().where((e) {
      return (e.widget as CustomPaint).painter is PixelShapePainter;
    }).length;
    expect(paintsWithPainter, 4);
  });
```

- [ ] **Step 2: Run tests — verify they pass**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: PASS (the skeleton already wires emptyStyle correctly via the ternary in `_tileFor`).

- [ ] **Step 3: Commit**

```bash
git add test/pixel_grid_test.dart
git commit -m "test: cover empty-slot rendering paths"
```

---

### Task 4: Assertion tests

**Files:**
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Append failing assertion tests**

```dart
  group('PixelGrid asserts', () {
    test('empty data throws', () {
      expect(
        () => PixelGrid<_Kind>.fromList(
          data: const [],
          tileLogicalWidth: 4,
          tileLogicalHeight: 4,
          tileScreenSize: const Size(16, 16),
          styleFor: _styleFor,
        ),
        throwsAssertionError,
      );
    });

    test('uneven rows throws', () {
      expect(
        () => PixelGrid<_Kind>.fromList(
          data: const [
            [_Kind.wall, _Kind.wall],
            [_Kind.wall],
          ],
          tileLogicalWidth: 4,
          tileLogicalHeight: 4,
          tileScreenSize: const Size(16, 16),
          styleFor: _styleFor,
        ),
        throwsAssertionError,
      );
    });

    test('rows <= 0 throws', () {
      expect(
        () => PixelGrid<_Kind>.builder(
          rows: 0,
          cols: 3,
          tileAt: (_, __) => null,
          tileLogicalWidth: 4,
          tileLogicalHeight: 4,
          tileScreenSize: const Size(16, 16),
          styleFor: _styleFor,
        ),
        throwsAssertionError,
      );
    });

    test('tileLogicalWidth <= 0 throws', () {
      expect(
        () => PixelGrid<_Kind>.builder(
          rows: 3,
          cols: 3,
          tileAt: (_, __) => null,
          tileLogicalWidth: 0,
          tileLogicalHeight: 4,
          tileScreenSize: const Size(16, 16),
          styleFor: _styleFor,
        ),
        throwsAssertionError,
      );
    });

    test('onTileAccept without dragDataFor throws', () {
      expect(
        () => PixelGrid<_Kind>.builder(
          rows: 3,
          cols: 3,
          tileAt: (_, __) => null,
          tileLogicalWidth: 4,
          tileLogicalHeight: 4,
          tileScreenSize: const Size(16, 16),
          styleFor: _styleFor,
          onTileAccept: (_, __, ___) {},
        ),
        throwsAssertionError,
      );
    });
  });
```

- [ ] **Step 2: Run tests — verify they pass**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: PASS (assertions added in Task 1 cover all cases).

- [ ] **Step 3: Commit**

```bash
git add test/pixel_grid_test.dart
git commit -m "test: assertion coverage for PixelGrid inputs"
```

---

## M2 — Tap + Focus

### Task 5: Tap callback wiring

**Files:**
- Modify: `lib/src/pixel_grid.dart`
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Add failing test**

Append to `test/pixel_grid_test.dart`:

```dart
  testWidgets('onTileTap invoked with (x, y) on tap', (tester) async {
    final taps = <(int, int)>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelGrid<_Kind>.fromList(
              data: const [
                [_Kind.wall, _Kind.floor, _Kind.wall],
                [_Kind.floor, _Kind.wall, _Kind.floor],
              ],
              tileLogicalWidth: 4,
              tileLogicalHeight: 4,
              tileScreenSize: const Size(16, 16),
              styleFor: _styleFor,
              onTileTap: (x, y) => taps.add((x, y)),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<(int, int)>((1, 0))));
    await tester.tap(find.byKey(const ValueKey<(int, int)>((0, 1))));
    expect(taps, [(1, 0), (0, 1)]);
  });
```

- [ ] **Step 2: Run test — verify it fails**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: FAIL — no GestureDetector wired yet.

- [ ] **Step 3: Add `_Tile` wrapper and wire `onTileTap`**

In `lib/src/pixel_grid.dart`, replace `_tileFor` in `_PixelGridState` and add a new `_Tile` widget above `_TilePaint`:

```dart
  Widget _tileFor(int x, int y) {
    final data = widget.tileAt(x, y);
    final style = data == null ? widget.emptyStyle : widget.styleFor(data);
    return _Tile<T>(
      key: ValueKey<(int, int)>((x, y)),
      x: x,
      y: y,
      data: data,
      style: style,
      tileLogicalWidth: widget.tileLogicalWidth,
      tileLogicalHeight: widget.tileLogicalHeight,
      tileScreenSize: widget.tileScreenSize,
      onTileTap: widget.onTileTap,
    );
  }
}

class _Tile<T> extends StatelessWidget {
  const _Tile({
    super.key,
    required this.x,
    required this.y,
    required this.data,
    required this.style,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    this.onTileTap,
  });

  final int x;
  final int y;
  final T? data;
  final PixelShapeStyle? style;
  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;
  final void Function(int x, int y)? onTileTap;

  @override
  Widget build(BuildContext context) {
    Widget tile = _TilePaint(
      style: style,
      tileLogicalWidth: tileLogicalWidth,
      tileLogicalHeight: tileLogicalHeight,
      tileScreenSize: tileScreenSize,
    );
    if (onTileTap != null) {
      tile = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTileTap!(x, y),
        child: tile,
      );
    }
    return tile;
  }
}
```

- [ ] **Step 4: Run test — verify it passes**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/pixel_grid.dart test/pixel_grid_test.dart
git commit -m "feat: PixelGrid onTileTap callback"
```

---

### Task 6: FocusNode + arrow-key navigation + focus outline

**Files:**
- Modify: `lib/src/pixel_grid.dart`
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Write failing keyboard tests**

Append:

```dart
  testWidgets('arrow keys move focus', (tester) async {
    final activates = <(int, int)>[];
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.builder(
            rows: 3,
            cols: 3,
            tileAt: (_, __) => _Kind.floor,
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            focusNode: focus,
            autofocus: true,
            onTileActivate: (x, y) => activates.add((x, y)),
          ),
        ),
      ),
    );
    await tester.pump();

    // Start focus at (0, 0), Right → (1, 0), Down → (1, 1), Enter → activate.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activates, [(1, 1)]);
  });

  testWidgets('arrow key at boundary is no-op', (tester) async {
    final activates = <(int, int)>[];
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.builder(
            rows: 2,
            cols: 2,
            tileAt: (_, __) => _Kind.floor,
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            focusNode: focus,
            autofocus: true,
            onTileActivate: (x, y) => activates.add((x, y)),
          ),
        ),
      ),
    );
    await tester.pump();

    // Try to go up from (0, 0). Should stay. Enter should activate (0, 0).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(activates, [(0, 0)]);
  });

  testWidgets('Enter/Space on null tile does NOT activate', (tester) async {
    final activates = <(int, int)>[];
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.fromList(
            data: const [
              [null, _Kind.floor],
            ],
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            focusNode: focus,
            autofocus: true,
            onTileActivate: (x, y) => activates.add((x, y)),
          ),
        ),
      ),
    );
    await tester.pump();

    // Focus starts at (0, 0) — null slot. Enter should be no-op.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activates, isEmpty);
  });
```

Also add the `flutter/services.dart` import at the top of the test file if not already there:

```dart
import 'package:flutter/services.dart';
```

- [ ] **Step 2: Run tests — verify they fail**

Run: `fvm flutter test test/pixel_grid_test.dart --plain-name "arrow"`
Expected: FAIL (no keyboard handling yet).

- [ ] **Step 3: Wire FocusNode + key handler + focus outline**

In `lib/src/pixel_grid.dart`:

Add `import 'package:flutter/services.dart';` at the top.

Replace `_PixelGridState` with:

```dart
class _PixelGridState<T> extends State<PixelGrid<T>> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  (int, int) _focused = (0, 0);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
  }

  @override
  void didUpdateWidget(covariant PixelGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  bool _isEnabled(int x, int y) =>
      widget.isTileEnabled?.call(x, y) ?? true;

  void _moveFocusBy(int dx, int dy) {
    final (fx, fy) = _focused;
    int nx = fx + dx;
    int ny = fy + dy;
    // Skip disabled tiles; stop at boundary without wrapping.
    while (nx >= 0 && nx < widget.cols && ny >= 0 && ny < widget.rows) {
      if (_isEnabled(nx, ny)) {
        setState(() => _focused = (nx, ny));
        return;
      }
      nx += dx;
      ny += dy;
    }
    // No enabled target in that direction: stay put.
  }

  void _moveFocusTo(int x, int y) {
    if (_focused == (x, y)) return;
    setState(() => _focused = (x, y));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _moveFocusBy(0, -1);
      case LogicalKeyboardKey.arrowDown:
        _moveFocusBy(0, 1);
      case LogicalKeyboardKey.arrowLeft:
        _moveFocusBy(-1, 0);
      case LogicalKeyboardKey.arrowRight:
        _moveFocusBy(1, 0);
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        final (fx, fy) = _focused;
        final data = widget.tileAt(fx, fy);
        if (data != null) widget.onTileActivate?.call(fx, fy);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int y = 0; y < widget.rows; y++) {
      final tiles = <Widget>[];
      for (int x = 0; x < widget.cols; x++) {
        tiles.add(_tileFor(x, y));
      }
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        spacing: widget.gap,
        children: tiles,
      ));
    }
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: widget.gap,
        children: rows,
      ),
    );
  }

  Widget _tileFor(int x, int y) {
    final data = widget.tileAt(x, y);
    final style = data == null ? widget.emptyStyle : widget.styleFor(data);
    return _Tile<T>(
      key: ValueKey<(int, int)>((x, y)),
      x: x,
      y: y,
      data: data,
      style: style,
      tileLogicalWidth: widget.tileLogicalWidth,
      tileLogicalHeight: widget.tileLogicalHeight,
      tileScreenSize: widget.tileScreenSize,
      onTileTap: widget.onTileTap == null
          ? null
          : (tx, ty) {
              widget.onTileTap!(tx, ty);
              _moveFocusTo(tx, ty);
              _focusNode.requestFocus();
            },
      focused: _focused == (x, y),
    );
  }
}
```

Update `_Tile<T>` — add `focused` field and overlay a `_FocusOutline`. Replace the existing class:

```dart
class _Tile<T> extends StatelessWidget {
  const _Tile({
    super.key,
    required this.x,
    required this.y,
    required this.data,
    required this.style,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.focused,
    this.onTileTap,
  });

  final int x;
  final int y;
  final T? data;
  final PixelShapeStyle? style;
  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;
  final bool focused;
  final void Function(int x, int y)? onTileTap;

  @override
  Widget build(BuildContext context) {
    Widget tile = Stack(
      children: [
        _TilePaint(
          style: style,
          tileLogicalWidth: tileLogicalWidth,
          tileLogicalHeight: tileLogicalHeight,
          tileScreenSize: tileScreenSize,
        ),
        if (focused) _FocusOutline(size: tileScreenSize),
      ],
    );
    if (onTileTap != null) {
      tile = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTileTap!(x, y),
        child: tile,
      );
    }
    return tile;
  }
}

class _FocusOutline extends StatelessWidget {
  const _FocusOutline({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests — verify they pass**

Run: `fvm flutter test test/pixel_grid_test.dart`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/pixel_grid.dart test/pixel_grid_test.dart
git commit -m "feat: PixelGrid keyboard focus + Enter/Space activate"
```

---

### Task 7: `isTileEnabled` skip-search

**Files:**
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Failing test**

Append:

```dart
  testWidgets('arrow keys skip disabled tiles', (tester) async {
    final activates = <(int, int)>[];
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.builder(
            rows: 1,
            cols: 5,
            tileAt: (_, __) => _Kind.floor,
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            focusNode: focus,
            autofocus: true,
            // Only even-x tiles are enabled. Starting at (0, 0).
            isTileEnabled: (x, y) => x.isEven,
            onTileActivate: (x, y) => activates.add((x, y)),
          ),
        ),
      ),
    );
    await tester.pump();

    // Right → skip (1, 0) disabled → land on (2, 0). Activate.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activates, [(2, 0)]);
  });
```

- [ ] **Step 2: Run test — verify it passes**

Run: `fvm flutter test test/pixel_grid_test.dart --plain-name "skip disabled"`
Expected: PASS (skip-search loop in `_moveFocusBy` already handles this).

- [ ] **Step 3: Commit**

```bash
git add test/pixel_grid_test.dart
git commit -m "test: PixelGrid skips disabled tiles on arrow-key nav"
```

---

## M3 — Drag & Drop

### Task 8: Draggable + DragTarget wiring

**Files:**
- Modify: `lib/src/pixel_grid.dart`
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Write failing drag test**

Append to `test/pixel_grid_test.dart`:

```dart
  testWidgets('drag from one tile to another invokes onTileAccept',
      (tester) async {
    ((int, int), (int, int), _Kind)? lastAccept;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelGrid<_Kind>.fromList(
              data: const [
                [_Kind.wall, null],
                [null, _Kind.floor],
              ],
              tileLogicalWidth: 4,
              tileLogicalHeight: 4,
              tileScreenSize: const Size(32, 32),
              styleFor: _styleFor,
              dragDataFor: (x, y) {
                // Only (0, 0) has wall, (1, 1) has floor — make them draggable.
                if (x == 0 && y == 0) return _Kind.wall;
                if (x == 1 && y == 1) return _Kind.floor;
                return null;
              },
              onTileAccept: (from, to, data) =>
                  lastAccept = (from, to, data),
            ),
          ),
        ),
      ),
    );

    final src = find.byKey(const ValueKey<(int, int)>((0, 0)));
    final dst = find.byKey(const ValueKey<(int, int)>((1, 1)));
    final srcCenter = tester.getCenter(src);
    final dstCenter = tester.getCenter(dst);

    final gesture = await tester.startGesture(srcCenter);
    // Must exceed kTouchSlop before the Draggable starts tracking.
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(dstCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(lastAccept, isNotNull);
    expect(lastAccept!.$1, (0, 0));
    expect(lastAccept!.$2, (1, 1));
    expect(lastAccept!.$3, _Kind.wall);
  });
```

- [ ] **Step 2: Run test — verify it fails**

Run: `fvm flutter test test/pixel_grid_test.dart --plain-name "drag from"`
Expected: FAIL — no Draggable/DragTarget wired.

- [ ] **Step 3: Add drag/drop to `_Tile`**

In `lib/src/pixel_grid.dart`, introduce the payload typedef and extend `_Tile<T>` to wrap `Draggable` + `DragTarget`. Replace `_Tile<T>`:

```dart
typedef _DragPayload<T> = ({(int, int) from, T payload});

class _Tile<T> extends StatelessWidget {
  const _Tile({
    super.key,
    required this.x,
    required this.y,
    required this.data,
    required this.style,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.focused,
    this.onTileTap,
    this.dragData,
    this.onTileAccept,
  });

  final int x;
  final int y;
  final T? data;
  final PixelShapeStyle? style;
  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;
  final bool focused;
  final void Function(int x, int y)? onTileTap;
  final T? dragData;
  final void Function((int, int) from, (int, int) to, T data)? onTileAccept;

  @override
  Widget build(BuildContext context) {
    final paint = _TilePaint(
      style: style,
      tileLogicalWidth: tileLogicalWidth,
      tileLogicalHeight: tileLogicalHeight,
      tileScreenSize: tileScreenSize,
    );
    Widget tile = Stack(
      children: [
        paint,
        if (focused) _FocusOutline(size: tileScreenSize),
      ],
    );

    if (dragData != null) {
      final payload = dragData as T;
      tile = Draggable<_DragPayload<T>>(
        data: (from: (x, y), payload: payload),
        feedback: Opacity(opacity: 0.7, child: paint),
        childWhenDragging: Opacity(opacity: 0.3, child: tile),
        child: tile,
      );
    }

    if (onTileAccept != null) {
      tile = DragTarget<_DragPayload<T>>(
        onAcceptWithDetails: (d) =>
            onTileAccept!(d.data.from, (x, y), d.data.payload),
        builder: (_, __, ___) => tile,
      );
    }

    if (onTileTap != null) {
      tile = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTileTap!(x, y),
        child: tile,
      );
    }

    return tile;
  }
}
```

Update `_tileFor` in `_PixelGridState` to pass the two new params:

```dart
  Widget _tileFor(int x, int y) {
    final data = widget.tileAt(x, y);
    final style = data == null ? widget.emptyStyle : widget.styleFor(data);
    final dragData = widget.dragDataFor?.call(x, y);
    return _Tile<T>(
      key: ValueKey<(int, int)>((x, y)),
      x: x,
      y: y,
      data: data,
      style: style,
      tileLogicalWidth: widget.tileLogicalWidth,
      tileLogicalHeight: widget.tileLogicalHeight,
      tileScreenSize: widget.tileScreenSize,
      focused: _focused == (x, y),
      onTileTap: widget.onTileTap == null
          ? null
          : (tx, ty) {
              widget.onTileTap!(tx, ty);
              _moveFocusTo(tx, ty);
              _focusNode.requestFocus();
            },
      dragData: dragData,
      onTileAccept: widget.onTileAccept,
    );
  }
```

- [ ] **Step 4: Run test — verify it passes**

Run: `fvm flutter test test/pixel_grid_test.dart --plain-name "drag from"`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/pixel_grid.dart test/pixel_grid_test.dart
git commit -m "feat: PixelGrid drag & drop via Draggable/DragTarget"
```

---

### Task 9: Non-draggable tile smoke test

**Files:**
- Modify: `test/pixel_grid_test.dart`

- [ ] **Step 1: Failing test**

Append:

```dart
  testWidgets('tile with null dragDataFor has no Draggable ancestor',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.fromList(
            data: const [
              [_Kind.wall, _Kind.floor],
            ],
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            dragDataFor: (x, y) => x == 0 ? _Kind.wall : null,
            onTileAccept: (_, __, ___) {},
          ),
        ),
      ),
    );

    // Tile (1, 0) should have no Draggable in its descendants.
    final nonDraggable = find.byKey(const ValueKey<(int, int)>((1, 0)));
    expect(
      find.descendant(
        of: nonDraggable,
        matching: find.byType(Draggable<_DragPayload<_Kind>>),
      ),
      findsNothing,
    );
  });
```

Note: `_DragPayload` is private to `pixel_grid.dart`. The test needs a workaround — since the type is private, match by `Draggable` base type with matcher:

Replace the final `expect` with:

```dart
    expect(
      find.descendant(
        of: nonDraggable,
        matching: find.byWidgetPredicate((w) => w is Draggable),
      ),
      findsNothing,
    );
```

Remove the problematic `find.byType(Draggable<_DragPayload<_Kind>>)` line above — keep only the `byWidgetPredicate` version.

- [ ] **Step 2: Run test — verify it passes**

Run: `fvm flutter test test/pixel_grid_test.dart --plain-name "no Draggable ancestor"`
Expected: PASS (Task 8 logic skips Draggable when `dragData == null`).

- [ ] **Step 3: Commit**

```bash
git add test/pixel_grid_test.dart
git commit -m "test: PixelGrid non-draggable tiles skip Draggable wrap"
```

---

## M4 — Export, Goldens, Gallery, Docs

### Task 10: Export + full suite sanity

**Files:**
- Modify: `lib/pixel_ui.dart`

- [ ] **Step 1: Add export**

Edit `lib/pixel_ui.dart`. Add after existing exports:

```dart
export 'src/pixel_grid.dart';
```

- [ ] **Step 2: Verify analyze + full test suite green**

Run: `fvm flutter analyze`
Expected: `No issues found!`

Run: `fvm flutter test --exclude-tags screenshot`
Expected: All tests PASS (previously 145, should be ~155+ now).

- [ ] **Step 3: Commit**

```bash
git add lib/pixel_ui.dart
git commit -m "feat: export PixelGrid from pixel_ui"
```

---

### Task 11: Golden tests — minimap + inventory with focus

**Files:**
- Create: `test/pixel_grid_golden_test.dart`
- Create: `test/goldens/pixel_grid/minimap_3x3.png`
- Create: `test/goldens/pixel_grid/inventory_2x2_focused.png`

- [ ] **Step 1: Write the golden test file**

```dart
// test/pixel_grid_golden_test.dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _boundaryKey = Key('pixel-grid-golden-boundary');

const _floor = PixelShapeStyle(
  corners: PixelCorners.sharp,
  fillColor: Color(0xFF3A3550),
);
const _wall = PixelShapeStyle(
  corners: PixelCorners.sharp,
  fillColor: Color(0xFF6F607A),
  borderColor: Color(0xFF453E5C),
  borderWidth: 1,
);
const _fog = PixelShapeStyle(
  corners: PixelCorners.sharp,
  fillColor: Color(0xFF0E0B14),
);

const _itemA = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFF5D76E),
);
const _itemB = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF85C1E9),
);
const _empty = PixelShapeStyle(
  corners: PixelCorners.sharp,
  fillColor: Color(0xFF222222),
);

enum _Tile { floor, wall, fog }

PixelShapeStyle _tileStyle(_Tile t) => switch (t) {
      _Tile.floor => _floor,
      _Tile.wall => _wall,
      _Tile.fog => _fog,
    };

void main() {
  testWidgets('minimap 3x3', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1E1A26),
          body: Center(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: PixelGrid<_Tile>.fromList(
                data: const [
                  [_Tile.wall, _Tile.floor, _Tile.wall],
                  [_Tile.floor, _Tile.floor, _Tile.fog],
                  [_Tile.fog, _Tile.floor, _Tile.wall],
                ],
                tileLogicalWidth: 5,
                tileLogicalHeight: 5,
                tileScreenSize: const Size(20, 20),
                styleFor: _tileStyle,
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_grid/minimap_3x3.png'),
    );
  });

  testWidgets('inventory 2x2 with focus', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1E1A26),
          body: Center(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: PixelGrid<PixelShapeStyle>.fromList(
                data: const [
                  [_itemA, null],
                  [null, _itemB],
                ],
                tileLogicalWidth: 8,
                tileLogicalHeight: 8,
                tileScreenSize: const Size(32, 32),
                styleFor: (s) => s,
                emptyStyle: _empty,
                focusNode: focus,
                autofocus: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_grid/inventory_2x2_focused.png'),
    );
  });
}
```

- [ ] **Step 2: Generate the golden files**

Run: `fvm flutter test --update-goldens test/pixel_grid_golden_test.dart`
Expected: PASS; `test/goldens/pixel_grid/minimap_3x3.png` and `inventory_2x2_focused.png` are created.

- [ ] **Step 3: Verify goldens lock (run again without `--update-goldens`)**

Run: `fvm flutter test test/pixel_grid_golden_test.dart`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add test/pixel_grid_golden_test.dart test/goldens/pixel_grid/
git commit -m "test: PixelGrid golden minimap + focused inventory"
```

---

### Task 12: Pub.dev screenshot scene

**Files:**
- Create: `test/screenshots/scenes/pixel_grid_scene.dart`
- Modify: `test/screenshots/screenshots_test.dart`
- Modify: `tool/update_screenshots.sh`

- [ ] **Step 1: Create the scene widget**

```dart
// test/screenshots/scenes/pixel_grid_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const _fill = Color(0xFF5A8A3A);
const _border = Color(0xFF2A4820);

const _itemGold = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFF5D76E),
  borderColor: Color(0xFFBF8B2E),
  borderWidth: 1,
);
const _itemBlue = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF85C1E9),
  borderColor: Color(0xFF2E86C1),
  borderWidth: 1,
);
const _itemGreen = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: _fill,
  borderColor: _border,
  borderWidth: 1,
);
const _slotEmpty = PixelShapeStyle(
  corners: PixelCorners.sharp,
  fillColor: Color(0xFF1E1A26),
  borderColor: Color(0xFF2A2733),
  borderWidth: 1,
);

PixelShapeStyle _styleFor(PixelShapeStyle s) => s;

class PixelGridScene extends StatelessWidget {
  const PixelGridScene({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenshotFrame(
      child: _Grid(),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PixelGrid<PixelShapeStyle>.fromList(
        data: const [
          [_itemGold, _itemBlue, null, _itemGreen],
          [null, _itemGold, _itemBlue, null],
          [_itemBlue, null, _itemGreen, _itemGold],
          [null, _itemGreen, null, _itemBlue],
        ],
        tileLogicalWidth: 10,
        tileLogicalHeight: 10,
        tileScreenSize: Size(72, 72),
        styleFor: _styleFor,
        emptyStyle: _slotEmpty,
        gap: 0,
      ),
    );
  }
}
```

- [ ] **Step 2: Register the scene in screenshots_test.dart**

Edit `test/screenshots/screenshots_test.dart`:

Add to imports:
```dart
import 'scenes/pixel_grid_scene.dart';
```

Add to the `scenes` list:
```dart
  final scenes = <(String, Widget)>[
    ('01_hero', const HeroScene()),
    ('02_corners', const CornersScene()),
    ('03_shadows', const ShadowsScene()),
    ('04_buttons', const ButtonsScene()),
    ('05_texture', const TextureScene()),
    ('06_pixel_grid', const PixelGridScene()),
  ];
```

- [ ] **Step 3: Add `06_pixel_grid` to update script**

Edit `tool/update_screenshots.sh`. Change the `expected` array:

```bash
expected=(01_hero 02_corners 03_shadows 04_buttons 05_texture 06_pixel_grid)
```

- [ ] **Step 4: Generate the screenshot**

Run: `./tool/update_screenshots.sh`
Expected: Regenerates goldens including `06_pixel_grid.png`, copies to `doc/screenshots/`.

- [ ] **Step 5: Commit**

```bash
git add test/screenshots/scenes/pixel_grid_scene.dart \
  test/screenshots/screenshots_test.dart \
  test/screenshots/goldens/06_pixel_grid.png \
  doc/screenshots/06_pixel_grid.png \
  tool/update_screenshots.sh
git commit -m "docs(screenshots): add pixel_grid pub.dev scene"
```

---

### Task 13: Example app demo section

**Files:**
- Modify: `example/lib/main.dart`

- [ ] **Step 1: Read existing example to find insertion point**

Run: `grep -n "class _ShowcaseScreen\|section\|_Section\|Widget build" example/lib/main.dart | head -20`

Identify the existing section pattern and where the showcase sections are composed.

- [ ] **Step 2: Add a `_PixelGridDemo` section**

Append to the bottom of `example/lib/main.dart`:

```dart
class _PixelGridDemo extends StatefulWidget {
  const _PixelGridDemo();

  @override
  State<_PixelGridDemo> createState() => _PixelGridDemoState();
}

class _PixelGridDemoState extends State<_PixelGridDemo> {
  static const _gridCols = 5;
  static const _gridRows = 3;

  late List<List<_Item?>> _grid = [
    [_Item.sword, _Item.potion, null, _Item.gem, _Item.potion],
    [null, _Item.sword, _Item.gem, null, _Item.potion],
    [_Item.gem, null, _Item.potion, _Item.sword, null],
  ];

  @override
  Widget build(BuildContext context) {
    return PixelGrid<_Item>.fromList(
      data: _grid,
      tileLogicalWidth: 10,
      tileLogicalHeight: 10,
      tileScreenSize: const Size(48, 48),
      styleFor: (item) => _styleFor(item),
      emptyStyle: const PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFF2A2733),
        borderColor: Color(0xFF45404F),
        borderWidth: 1,
      ),
      dragDataFor: (x, y) => _grid[y][x],
      onTileAccept: (from, to, data) => setState(() {
        final (fx, fy) = from;
        final (tx, ty) = to;
        final tmp = _grid[ty][tx];
        _grid[ty][tx] = data;
        _grid[fy][fx] = tmp;
      }),
      onTileActivate: (x, y) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 600),
          content: Text('Activated (${x},${y}): ${_grid[y][x]?.name ?? "empty"}'),
        ),
      ),
      autofocus: true,
    );
  }
}

enum _Item { sword, potion, gem }

PixelShapeStyle _styleFor(_Item item) {
  switch (item) {
    case _Item.sword:
      return const PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFCCCCCC),
        borderColor: Color(0xFF666666),
        borderWidth: 1,
      );
    case _Item.potion:
      return const PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFC0392B),
        borderColor: Color(0xFF6B1E14),
        borderWidth: 1,
      );
    case _Item.gem:
      return const PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF85C1E9),
        borderColor: Color(0xFF2E86C1),
        borderWidth: 1,
      );
  }
}
```

- [ ] **Step 3: Insert `_PixelGridDemo` into the showcase screen**

Find the list/column of showcase sections in `_ShowcaseScreen.build` (or whichever widget composes them), and append `const _PixelGridDemo()` alongside a section header, matching the existing pattern. If headers are in the form `_SectionHeader(title: '...')` or similar, prefix the grid with a matching header labeled `'PixelGrid — inventory (drag to swap, arrow keys to navigate)'`.

Example insertion (adjust to actual code):

```dart
// Inside _ShowcaseScreen's column children, at the end:
const SizedBox(height: 24),
const _SectionHeader(title: 'PixelGrid — inventory'),
const SizedBox(height: 12),
const _PixelGridDemo(),
```

If you cannot locate the pattern, fall back to simply appending at the end of the scroll view's children.

- [ ] **Step 4: Verify example builds**

Run: `cd example && fvm flutter analyze && cd ..`
Expected: `No issues found!`

Run: `cd example && fvm flutter pub get && cd ..` (should be a no-op — already resolved)

- [ ] **Step 5: Commit**

```bash
git add example/lib/main.dart
git commit -m "docs(example): showcase PixelGrid inventory demo"
```

---

### Task 14: README Usage subsection + Gallery cell

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add "Tile grids" subsection under `## Usage`**

Insert after the existing "Direct CustomPaint integration" subsection in `README.md`:

```markdown
### Tile grids

`PixelGrid<T>` lays out a 2D grid of `PixelShapePainter` tiles with
optional keyboard focus, tap callbacks, and `Draggable<T>`/`DragTarget<T>`
drag-and-drop. Use `.fromList` for static data or `.builder` for
procedural/large maps:

```dart
import 'package:pixel_ui/pixel_ui.dart';

enum Slot { sword, potion }

PixelGrid<Slot>.fromList(
  data: const [
    [Slot.sword, null],
    [null,       Slot.potion],
  ],
  tileLogicalWidth: 10,
  tileLogicalHeight: 10,
  tileScreenSize: const Size(48, 48),
  styleFor: (s) => s == Slot.sword ? swordStyle : potionStyle,
  emptyStyle: emptySlotStyle,
  dragDataFor: (x, y) => grid[y][x],  // null → non-draggable tile
  onTileAccept: (from, to, payload) { /* swap / merge / reject */ },
  onTileActivate: (x, y) { /* arrow keys + Enter/Space or a tap */ },
  autofocus: true,
)
```

Data indexing is `data[y][x]` (outer list = rows). Enter/Space activates
the focused tile only when its data is non-null — empty slots are not
"activatable".
```

- [ ] **Step 2: Add Gallery cell for 06_pixel_grid**

In `README.md`, find the existing `## Gallery` table. Extend it with a third row:

```markdown
| Buttons | Texture |
| --- | --- |
| ![PixelButton states: normal, pressed, disabled](doc/screenshots/04_buttons.png) | ![Deterministic LCG texture overlay — plain vs textured](doc/screenshots/05_texture.png) |

| Tile grids | |
| --- | --- |
| ![PixelGrid inventory with drag & focus](doc/screenshots/06_pixel_grid.png) | |
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: README Tile grids usage + Gallery cell"
```

---

### Task 15: CHANGELOG entry + version bump + pubspec screenshots

**Files:**
- Modify: `CHANGELOG.md`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add 0.5.0 entry at the top of CHANGELOG.md**

Replace the header with a new top entry. In `CHANGELOG.md`, change:

```markdown
# Changelog

## 0.4.1 — 2026-04-24
```

to:

```markdown
# Changelog

## 0.5.0 — 2026-04-24

### Added
- `PixelGrid<T>` — tile-based layout widget for minimaps, inventories, tile maps, and similar 2D compositions (#36). Backed by `PixelShapePainter`. Supports:
  - `.fromList(data: List<List<T?>>)` for static grids; `.builder(rows, cols, tileAt)` for procedural/large maps.
  - Tap callback (`onTileTap`), keyboard focus with arrow-key navigation, Enter/Space activation (`onTileActivate`), and `isTileEnabled` skip-search.
  - `Draggable<T>` + `DragTarget<T>` drag-and-drop via `dragDataFor` + `onTileAccept((from, to, data))`.
  - Empty slots via `null` data + optional `emptyStyle` fallback.

## 0.4.1 — 2026-04-24
```

- [ ] **Step 2: Bump version + register screenshot**

Edit `pubspec.yaml`:

Change:
```yaml
version: 0.4.1
```
to:
```yaml
version: 0.5.0
```

Add a new entry to the `screenshots:` list:
```yaml
  - description: "Tile grid — drag to swap, arrow keys to navigate"
    path: doc/screenshots/06_pixel_grid.png
```

- [ ] **Step 3: Verify analyze + full test suite**

Run: `fvm flutter analyze`
Expected: `No issues found!`

Run: `fvm flutter test --exclude-tags screenshot`
Expected: All PASS.

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md pubspec.yaml
git commit -m "chore: bump version to 0.5.0 + register grid screenshot"
```

---

## M5 — Release

### Task 16: Push branch, open PR, watch CI, merge

- [ ] **Step 1: Push branch**

Run: `git push -u origin feat/dogfood-36-pixel-grid`
Expected: Branch pushed; remote prints PR URL hint.

- [ ] **Step 2: Open PR**

```bash
gh pr create --title "feat: PixelGrid<T> tile-based layout widget (closes #36)" --body "$(cat <<'EOF'
Closes #36

## 변경사항
Introduces `PixelGrid<T>` — a tile-based layout widget backed by `PixelShapePainter`. Covers the widget-gap discovered in dogfood cycle #2 (roguelike minimap use case) and extends naturally to inventories, world maps, and monster catalogs.

### Features
- `.fromList(List<List<T?>>)` / `.builder(rows, cols, tileAt)` constructors.
- Tap (`onTileTap`), keyboard focus with arrow-key nav + Enter/Space activate (`onTileActivate`), disabled-tile skip-search (`isTileEnabled`).
- Drag & drop via `Draggable<T>`/`DragTarget<T>` (`dragDataFor` + `onTileAccept`).
- Empty slots through `null` data and optional `emptyStyle`.

### Non-goals (tracked as follow-ups)
- Tuner integration — separate issue.
- Viewport virtualization, non-rectangular grids, drag feedback customization.

### Design & plan
- Spec: `docs/superpowers/specs/2026-04-24-pixel-grid-design.md`
- Plan: `docs/superpowers/plans/2026-04-24-pixel-grid-implementation.md`

## 검증
- [x] flutter analyze
- [x] flutter test --exclude-tags screenshot
- [x] widget-gap 8-항목 체크리스트 완료 (API 설계 / export / 단위 테스트 / 골든 / README Gallery / CHANGELOG / example / tuner 판단(분리))

## 스크린샷
![PixelGrid inventory](doc/screenshots/06_pixel_grid.png)
EOF
)"
```

- [ ] **Step 3: Watch CI**

Run: `gh pr checks <PR_NUMBER> --watch`
Expected: All 7 jobs PASS (Analyze + Test + Publish dry-run, Build apk/ios/linux/macos/web/windows).

- [ ] **Step 4: Squash & merge**

Run: `gh pr merge <PR_NUMBER> --squash --delete-branch`
Expected: Fast-forward into main; branch deleted.

- [ ] **Step 5: Tag v0.5.0 and push — triggers publish.yml**

```bash
git checkout main
git pull origin main
git tag -a v0.5.0 -m "v0.5.0 — PixelGrid<T> widget"
git push origin main v0.5.0
```

- [ ] **Step 6: Watch publish workflow**

Run: `gh run list --limit 1 --workflow publish.yml --json databaseId -q '.[0].databaseId' | xargs -I{} gh run watch {} --exit-status`
Expected: 12 steps PASS; new GitHub release + pub.dev 0.5.0 published.

- [ ] **Step 7: Link issue**

Run: `gh issue comment 36 --body "Shipped in v0.5.0 (#<PR_NUMBER>)."`

---

## Self-Review

### Spec coverage check
- §1 Overview → Task 1 scaffolds, all later tasks build on it. ✓
- §2 Public API → Task 1 defines full surface, Tasks 2-8 implement behavior. ✓
- §3 Internal Architecture → `_PixelGridState` (Task 6), `_Tile` (Tasks 5, 8), `_TilePaint` (Task 2), `_DragPayload` typedef (Task 8), `_FocusOutline` (Task 6). ✓
- §4-a gap → handled in Row/Column `spacing` (Task 6 build method). ✓
- §4-b Tap → Task 5 + Task 6 (focus propagation). ✓
- §4-c Keyboard → Task 6 (`_handleKey`) + Task 7 (disabled skip). ✓
- §4-d Drag/drop → Task 8. ✓
- §5 Asserts → Task 4. ✓
- §6 Tests → unit/widget (Tasks 2-9), golden (Task 11). ✓
- §7 README + Gallery + example → Tasks 13, 14. ✓
- §8 Checklist mapping → Tasks 10 (export), 2-9 (unit tests), 11 (goldens), 14 (README), 15 (CHANGELOG), 13 (example), T-B (tuner deferred). ✓
- §9 Follow-ups → explicitly out-of-scope; no tasks. ✓
- §10 Milestones → maps to task groups M1-M5. ✓

### Placeholder scan
No "TBD"/"TODO"/"fill in later" remain. All code blocks complete and executable.

### Type consistency
- `_DragPayload<T>` typedef used consistently in Tasks 8, 9.
- `_Tile<T>` / `_TilePaint` names stable across tasks.
- `onTileAccept` signature `((int, int) from, (int, int) to, T data)` consistent in spec, Task 1 (decl), Task 8 (use), Task 9 (test signature).
- `tileLogicalWidth` / `tileLogicalHeight` (int) consistent everywhere.
- `_focused = (0, 0)` default — anchored at the first tile per spec; keyboard tests rely on this in Task 6.
