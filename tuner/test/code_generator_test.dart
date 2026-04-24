import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/code_generator.dart';

void main() {
  group('generateCode', () {
    test('preset corners emit preset identifier', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final code = generateCode(style);
      expect(code, contains('corners: PixelCorners.lg,'));
      expect(code, contains('fillColor: Color(0xFF5A8A3A),'));
    });

    test('null borderColor omits both borderColor and borderWidth lines', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFFFFFFFF),
        borderWidth: 3, // should still be omitted because borderColor is null
      );
      final code = generateCode(style);
      expect(code, isNot(contains('borderColor:')));
      expect(code, isNot(contains('borderWidth:')));
    });

    test('null shadow omits shadow block entirely', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
      );
      expect(generateCode(style), isNot(contains('shadow:')));
    });

    test('shadow present emits nested block with offset and color', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
        shadow: PixelShadow(offset: Offset(2, -1), color: Color(0xFF123456)),
      );
      final code = generateCode(style);
      expect(code, contains('shadow: PixelShadow('));
      expect(code, contains('offset: Offset(2, -1),'));
      expect(code, contains('color: Color(0xFF123456),'));
    });

    test('solid shadow style is omitted from emitted source', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
        shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF000000)),
      );
      expect(generateCode(style), isNot(contains('style:')));
    });

    test('stipple shadow style is emitted as PixelShadowStyle.stipple', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
        shadow: PixelShadow(
          offset: Offset(1, 1),
          color: Color(0xFF000000),
          style: PixelShadowStyle.stipple,
        ),
      );
      expect(
        generateCode(style),
        contains('style: PixelShadowStyle.stipple,'),
      );
    });

    test('output uses 2-space indent', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final code = generateCode(style);
      expect(code, startsWith('const style = PixelShapeStyle(\n  corners: '));
    });

    test('fillColor uses uppercase 8-digit hex with 0xFF prefix', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFFAABBCC),
      );
      expect(generateCode(style), contains('Color(0xFFAABBCC)'));
    });
  });
}
