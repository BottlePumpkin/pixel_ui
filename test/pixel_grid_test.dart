import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

int _painterCount(WidgetTester tester) =>
    find.byType(CustomPaint).evaluate().where((e) {
      return (e.widget as CustomPaint).painter is PixelShapePainter;
    }).length;

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
    expect(_painterCount(tester), 15);
  });

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

    // 2 non-null tiles only (out of 4 slots).
    expect(_painterCount(tester), 2);
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
    expect(_painterCount(tester), 4);
  });

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
            tileAt: (_, _) => _Kind.floor,
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
            tileAt: (_, _) => _Kind.floor,
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

  testWidgets('swapping external FocusNode does not dispose it', (tester) async {
    final nodeA = FocusNode(debugLabel: 'A');
    final nodeB = FocusNode(debugLabel: 'B');
    addTearDown(nodeA.dispose);
    addTearDown(nodeB.dispose);

    Widget buildWith(FocusNode node) {
      return MaterialApp(
        home: Scaffold(
          body: PixelGrid<_Kind>.builder(
            rows: 2,
            cols: 2,
            tileAt: (_, _) => _Kind.floor,
            tileLogicalWidth: 4,
            tileLogicalHeight: 4,
            tileScreenSize: const Size(16, 16),
            styleFor: _styleFor,
            focusNode: node,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWith(nodeA));
    await tester.pumpWidget(buildWith(nodeB));
    // If nodeA was disposed, calling canRequestFocus would throw.
    expect(nodeA.canRequestFocus, isTrue);
    expect(nodeB.canRequestFocus, isTrue);
  });

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
            tileAt: (_, _) => _Kind.floor,
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
    await tester.pump();
    await gesture.moveTo(dstCenter);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(lastAccept, isNotNull);
    expect(lastAccept!.$1, (0, 0));
    expect(lastAccept!.$2, (1, 1));
    expect(lastAccept!.$3, _Kind.wall);
  });

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
          tileAt: (_, _) => null,
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
          tileAt: (_, _) => null,
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
          tileAt: (_, _) => null,
          tileLogicalWidth: 4,
          tileLogicalHeight: 4,
          tileScreenSize: const Size(16, 16),
          styleFor: _styleFor,
          onTileAccept: (_, _, _) {},
        ),
        throwsAssertionError,
      );
    });
  });
}
