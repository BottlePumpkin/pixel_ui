import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/widgets/box/box_code.dart';

void main() {
  group('generateBoxCode', () {
    test('preset corners emit preset identifier', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final code = generateBoxCode(style);
      expect(code, contains('corners: PixelCorners.lg,'));
      expect(code, contains('fillColor: Color(0xFF5A8A3A),'));
    });

    test('null borderColor omits both borderColor and borderWidth lines', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFFFFFFFF),
        borderWidth: 3,
      );
      final code = generateBoxCode(style);
      expect(code, isNot(contains('borderColor:')));
      expect(code, isNot(contains('borderWidth:')));
    });

    test('null shadow omits shadow block entirely', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
      );
      expect(generateBoxCode(style), isNot(contains('shadow:')));
    });

    test('shadow present emits nested block with offset and color', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
        shadow: PixelShadow(offset: Offset(2, -1), color: Color(0xFF123456)),
      );
      final code = generateBoxCode(style);
      expect(code, contains('shadow: PixelShadow('));
      expect(code, contains('offset: Offset(2, -1),'));
      expect(code, contains('color: Color(0xFF123456),'));
    });

    test('omitting labelText produces no label comment block', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
      );
      expect(generateBoxCode(style), isNot(contains('Paired usage')));
      expect(generateBoxCode(style), isNot(contains('label:')));
    });

    test('non-null labelText emits PixelBox usage comment', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
      );
      final code = generateBoxCode(style, labelText: 'INVENTORY');
      expect(code, contains('// Paired usage:'));
      expect(code, contains("//   label: Text('INVENTORY'),"));
    });

    test('label with single quote is escaped', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
      );
      final code = generateBoxCode(style, labelText: "it's");
      expect(code, contains(r"//   label: Text('it\'s'),"));
    });

    test('output uses 2-space indent', () {
      const style = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final code = generateBoxCode(style);
      expect(code, startsWith('const style = PixelShapeStyle(\n  corners: '));
    });
  });
}
