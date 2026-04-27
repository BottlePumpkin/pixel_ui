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
