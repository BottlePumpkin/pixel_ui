import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
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
