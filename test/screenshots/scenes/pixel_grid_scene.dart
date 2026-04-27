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
    return ScreenshotFrame(
      title: 'PixelGrid',
      body: const _Grid(),
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
