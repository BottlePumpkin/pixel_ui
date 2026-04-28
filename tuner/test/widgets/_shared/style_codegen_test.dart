import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/widgets/_shared/style_codegen.dart';

void main() {
  group('emitColor', () {
    test('uppercase 8-digit hex with 0x prefix', () {
      expect(emitColor(const Color(0xFFAABBCC)), 'Color(0xFFAABBCC)');
    });

    test('preserves alpha bits', () {
      expect(emitColor(const Color(0x80123456)), 'Color(0x80123456)');
    });
  });

  group('emitCorners', () {
    test('preset identity returns preset literal', () {
      expect(emitCorners(PixelCorners.lg), 'PixelCorners.lg');
      expect(emitCorners(PixelCorners.sharp), 'PixelCorners.sharp');
    });

    test('reconstructed equivalent of preset emits preset literal', () {
      const reconstructed = PixelCorners.all(<int>[]);
      expect(emitCorners(reconstructed), 'PixelCorners.sharp');
    });

    test('custom symmetric pattern emits PixelCorners.all([...])', () {
      const custom = PixelCorners.all([4, 3, 2, 1]);
      expect(emitCorners(custom), 'PixelCorners.all([4, 3, 2, 1])');
    });
  });

  group('emitShadowLines', () {
    test('solid-style shadow omits style line', () {
      const s = PixelShadow(offset: Offset(1, 2), color: Color(0xFF000000));
      final lines = emitShadowLines(s);
      expect(lines, contains('  shadow: PixelShadow('));
      expect(lines.any((l) => l.contains('offset: Offset(1, 2)')), isTrue);
      expect(lines.any((l) => l.contains('style:')), isFalse);
    });

    test('stipple-style shadow emits style line', () {
      const s = PixelShadow(
        offset: Offset(1, 1),
        color: Color(0xFF000000),
        style: PixelShadowStyle.stipple,
      );
      final lines = emitShadowLines(s);
      expect(lines.any((l) => l.contains('style: PixelShadowStyle.stipple')),
          isTrue);
    });

    test('lines end with closing paren-comma', () {
      const s = PixelShadow(offset: Offset(0, 1), color: Color(0xFF000000));
      final lines = emitShadowLines(s);
      expect(lines.last, '  ),');
    });
  });

  group('emitTextureLines', () {
    test('emits PixelTexture block with all fields', () {
      const t = PixelTexture(
        color: Color(0xFFAABBCC),
        density: 0.4,
        size: 2,
        seed: 7,
      );
      final lines = emitTextureLines(t);
      expect(lines.first, '  texture: PixelTexture(');
      expect(lines.any((l) => l.contains('density: 0.4')), isTrue);
      expect(lines.any((l) => l.contains('size: 2')), isTrue);
      expect(lines.any((l) => l.contains('seed: 7')), isTrue);
      expect(lines.any((l) => l.contains('color: Color(0xFFAABBCC)')), isTrue);
      expect(lines.last, '  ),');
    });
  });

  group('emitStyleConst', () {
    test('minimal style: corners + fillColor', () {
      const s = PixelShapeStyle(
        corners: PixelCorners.lg,
        fillColor: Color(0xFF5A8A3A),
      );
      final lines = emitStyleConst(s, 'style');
      expect(lines.first, 'const style = PixelShapeStyle(');
      expect(lines, contains('  corners: PixelCorners.lg,'));
      expect(lines, contains('  fillColor: Color(0xFF5A8A3A),'));
      expect(lines.last, ');');
    });

    test('null borderColor omits both borderColor and borderWidth', () {
      const s = PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: Color(0xFFFFFFFF),
        borderWidth: 3,
      );
      final lines = emitStyleConst(s, 'style');
      expect(lines.any((l) => l.contains('borderColor:')), isFalse);
      expect(lines.any((l) => l.contains('borderWidth:')), isFalse);
    });

    test('non-null shadow nests inside the const block', () {
      const s = PixelShapeStyle(
        corners: PixelCorners.md,
        fillColor: Color(0xFF000000),
        shadow: PixelShadow(offset: Offset(2, -1), color: Color(0xFF123456)),
      );
      final lines = emitStyleConst(s, 'style');
      expect(lines.any((l) => l.contains('shadow: PixelShadow(')), isTrue);
      expect(lines.any((l) => l.contains('offset: Offset(2, -1)')), isTrue);
    });

    test('custom variable name', () {
      const s = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF111111),
      );
      final lines = emitStyleConst(s, 'thumb');
      expect(lines.first, 'const thumb = PixelShapeStyle(');
    });
  });
}
