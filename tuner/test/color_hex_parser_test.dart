import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui_tuner/src/color_hex_parser.dart';

void main() {
  group('parseHex', () {
    test('parses 6-hex with leading hash as opaque RGB', () {
      expect(parseHex('#AABBCC'), const Color(0xFFAABBCC));
    });

    test('parses 6-hex without leading hash', () {
      expect(parseHex('aabbcc'), const Color(0xFFAABBCC));
    });

    test('parses 8-hex as ARGB', () {
      expect(parseHex('FF112233'), const Color(0xFF112233));
      expect(parseHex('80112233'), const Color(0x80112233));
    });

    test('accepts uppercase and lowercase', () {
      expect(parseHex('aBcDeF'), const Color(0xFFABCDEF));
    });

    test('returns null for too-short input', () {
      expect(parseHex('12'), isNull);
      expect(parseHex(''), isNull);
    });

    test('returns null for non-hex characters', () {
      expect(parseHex('XYZ123'), isNull);
      expect(parseHex('#GGHHII'), isNull);
    });

    test('returns null for 7-char (between 6 and 8)', () {
      expect(parseHex('1234567'), isNull);
    });
  });
}
