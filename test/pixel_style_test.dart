import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  group('PixelShapeStyle', () {
    const base = PixelShapeStyle(
      corners: PixelCorners.md,
      fillColor: Color(0xFFAA0000),
      borderColor: Color(0xFF550000),
      borderWidth: 1,
      shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF220000)),
    );

    test('equality and hashCode', () {
      const a = PixelShapeStyle(corners: PixelCorners.md, fillColor: Color(0xFFFF0000));
      const b = PixelShapeStyle(corners: PixelCorners.md, fillColor: Color(0xFFFF0000));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    group('copyWith sentinel pattern', () {
      test('omitting a parameter keeps the original value', () {
        final result = base.copyWith(fillColor: const Color(0xFFBB0000));
        expect(result.borderColor, base.borderColor);
        expect(result.shadow, base.shadow);
      });

      test('explicit null clears a nullable field', () {
        final result = base.copyWith(borderColor: null);
        expect(result.borderColor, isNull);
        expect(result.fillColor, base.fillColor);
      });

      test('new value replaces a nullable field', () {
        const newShadow = PixelShadow(offset: Offset(3, 3), color: Color(0xFFFF0000));
        final result = base.copyWith(shadow: newShadow);
        expect(result.shadow, newShadow);
      });

      test('clearing shadow yields null shadow', () {
        final result = base.copyWith(shadow: null);
        expect(result.shadow, isNull);
      });

      test('clearing texture preserves other fields', () {
        const withTexture = PixelShapeStyle(
          corners: PixelCorners.sm,
          fillColor: Color(0xFF00FF00),
          texture: PixelTexture(color: Color(0xFFFFFFFF)),
        );
        final result = withTexture.copyWith(texture: null);
        expect(result.texture, isNull);
        expect(result.fillColor, const Color(0xFF00FF00));
      });

      test('non-nullable fields respect original if omitted', () {
        final result = base.copyWith();
        expect(result.corners, base.corners);
        expect(result.fillColor, base.fillColor);
        expect(result.borderWidth, base.borderWidth);
      });

      test('non-nullable fields replaced when provided', () {
        final result = base.copyWith(
          corners: PixelCorners.xl,
          fillColor: const Color(0xFF00FF00),
          borderWidth: 3,
        );
        expect(result.corners, PixelCorners.xl);
        expect(result.fillColor, const Color(0xFF00FF00));
        expect(result.borderWidth, 3);
      });
    });
  });

  group('PixelTexture', () {
    test('equality checks all fields', () {
      const a = PixelTexture(color: Color(0xFFFFFFFF), density: 0.2, size: 2, seed: 7);
      const b = PixelTexture(color: Color(0xFFFFFFFF), density: 0.2, size: 2, seed: 7);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different density is not equal', () {
      const a = PixelTexture(color: Color(0xFFFFFFFF), density: 0.1);
      const b = PixelTexture(color: Color(0xFFFFFFFF), density: 0.2);
      expect(a, isNot(equals(b)));
    });
  });

  group('PixelShadow', () {
    test('equality checks offset and color', () {
      const a = PixelShadow(offset: Offset(1, 1), color: Color(0xFF000000));
      const b = PixelShadow(offset: Offset(1, 1), color: Color(0xFF000000));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different offsets are not equal', () {
      const a = PixelShadow(offset: Offset(1, 1), color: Color(0xFF000000));
      const b = PixelShadow(offset: Offset(2, 2), color: Color(0xFF000000));
      expect(a, isNot(equals(b)));
    });

    test('PixelShadow.sm uses offset (1,1)', () {
      final shadow = PixelShadow.sm(const Color(0xFFAA0000));
      expect(shadow.offset, const Offset(1, 1));
      expect(shadow.color, const Color(0xFFAA0000));
    });

    test('PixelShadow.md uses offset (2,2)', () {
      final shadow = PixelShadow.md(const Color(0xFF00AA00));
      expect(shadow.offset, const Offset(2, 2));
    });

    test('PixelShadow.lg uses offset (4,4)', () {
      final shadow = PixelShadow.lg(const Color(0xFF0000AA));
      expect(shadow.offset, const Offset(4, 4));
    });
  });

  group('PixelCorners', () {
    test('equality uses listEquals on all four corners', () {
      const a = PixelCorners.all([3, 2, 1]);
      const b = PixelCorners.all([3, 2, 1]);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different corner lists are not equal', () {
      const a = PixelCorners.all([3, 2, 1]);
      const b = PixelCorners.all([3, 2]);
      expect(a, isNot(equals(b)));
    });

    test('only constructor defaults missing corners to empty', () {
      const corners = PixelCorners.only(tl: [1]);
      expect(corners.tl, [1]);
      expect(corners.tr, isEmpty);
      expect(corners.bl, isEmpty);
      expect(corners.br, isEmpty);
    });

    test('topInsetRows returns max of tl and tr lengths', () {
      const corners = PixelCorners.only(tl: [1, 2, 3], tr: [1]);
      expect(corners.topInsetRows, 3);
    });

    test('bottomInsetRows returns max of bl and br lengths', () {
      const corners = PixelCorners.only(bl: [1], br: [1, 2]);
      expect(corners.bottomInsetRows, 2);
    });

    test('static constants expose expected stair patterns', () {
      expect(PixelCorners.sharp.tl, isEmpty);
      expect(PixelCorners.xs.tl, [1]);
      expect(PixelCorners.sm.tl, [2, 1]);
      expect(PixelCorners.md.tl, [3, 2, 1]);
      expect(PixelCorners.lg.tl, [4, 2, 1, 1]);
      expect(PixelCorners.xl.tl, [6, 5, 4, 3, 2, 1]);
    });
  });
}
