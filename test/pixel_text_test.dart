import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  group('PixelText namespace', () {
    test('mulmaruFontFamily constant is Mulmaru', () {
      expect(PixelText.mulmaruFontFamily, 'Mulmaru');
    });

    test('mulmaruPackage constant is pixel_ui', () {
      expect(PixelText.mulmaruPackage, 'pixel_ui');
    });

    test('mulmaru() returns TextStyle with bundled font settings', () {
      final style = PixelText.mulmaru(fontSize: 20, color: const Color(0xFFAA0000));
      expect(style.fontSize, 20);
      expect(style.color, const Color(0xFFAA0000));
      expect(style.height, 1.0);
      expect(style.shadows, isNull);
    });

    test('mulmaru() applies single shadow when shadowColor given', () {
      final style = PixelText.mulmaru(
        shadowColor: const Color(0xFF000000),
        shadowOffset: const Offset(2, 2),
      );
      expect(style.shadows, hasLength(1));
      expect(style.shadows!.first.offset, const Offset(2, 2));
      expect(style.shadows!.first.color, const Color(0xFF000000));
    });

    test('mulmaru() omits shadows when neither shadowColor nor shadows given', () {
      final style = PixelText.mulmaru();
      expect(style.shadows, isNull);
    });

    test('mulmaru() uses explicit shadows list over shadowColor', () {
      const customShadows = [
        Shadow(offset: Offset(3, 3), color: Color(0xFFFF0000)),
        Shadow(offset: Offset(1, 1), color: Color(0xFF00FF00)),
      ];
      final style = PixelText.mulmaru(
        shadowColor: const Color(0xFF000000),
        shadows: customShadows,
      );
      expect(style.shadows, equals(customShadows));
    });

    test('mulmaru() passes through fontWeight and letterSpacing', () {
      final style = PixelText.mulmaru(
        fontWeight: FontWeight.w500,
        letterSpacing: 3.4,
      );
      expect(style.fontWeight, FontWeight.w500);
      expect(style.letterSpacing, 3.4);
    });
  });
}
