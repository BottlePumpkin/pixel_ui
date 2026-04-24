// Tests for PixelShapePainter.canvasSizeFor — the helper introduced
// alongside the dartdoc expansion for #35.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _baseStyle = PixelShapeStyle(
  corners: PixelCorners.sharp,
  fillColor: Color(0xFFFF0000),
);

void main() {
  group('PixelShapePainter.canvasSizeFor', () {
    test('no shadow → logical × scale', () {
      final size = PixelShapePainter.canvasSizeFor(
        style: _baseStyle,
        logicalWidth: 16,
        logicalHeight: 16,
        scale: 4,
      );
      expect(size, const Size(64, 64));
    });

    test('positive shadow offset extends both axes', () {
      final size = PixelShapePainter.canvasSizeFor(
        style: _baseStyle.copyWith(
          shadow: PixelShadow.md(const Color(0xFF000000)), // (2, 2)
        ),
        logicalWidth: 16,
        logicalHeight: 16,
        scale: 4,
      );
      expect(size, const Size(72, 72)); // (16+2)*4
    });

    test('negative shadow offset uses absolute value', () {
      final size = PixelShapePainter.canvasSizeFor(
        style: _baseStyle.copyWith(
          shadow: const PixelShadow(
            offset: Offset(-3, -1),
            color: Color(0xFF000000),
          ),
        ),
        logicalWidth: 10,
        logicalHeight: 10,
        scale: 4,
      );
      expect(size, const Size(52, 44)); // (10+3)*4, (10+1)*4
    });

    test('scale defaults to 4 (matches PixelBox convention)', () {
      final size = PixelShapePainter.canvasSizeFor(
        style: _baseStyle,
        logicalWidth: 5,
        logicalHeight: 5,
      );
      expect(size, const Size(20, 20));
    });

    test('custom scale honored', () {
      final size = PixelShapePainter.canvasSizeFor(
        style: _baseStyle,
        logicalWidth: 8,
        logicalHeight: 4,
        scale: 2.5,
      );
      expect(size, const Size(20, 10));
    });

    test('asymmetric shadow offsets', () {
      final size = PixelShapePainter.canvasSizeFor(
        style: _baseStyle.copyWith(
          shadow: const PixelShadow(
            offset: Offset(4, -1),
            color: Color(0xFF000000),
          ),
        ),
        logicalWidth: 16,
        logicalHeight: 16,
        scale: 4,
      );
      expect(size, const Size(80, 68)); // (16+4)*4, (16+1)*4
    });
  });
}
