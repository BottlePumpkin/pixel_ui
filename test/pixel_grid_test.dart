import 'package:flutter/material.dart';
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
}
