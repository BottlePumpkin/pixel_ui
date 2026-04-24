import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  group('PixelBoxCutout', () {
    test('defaults height to 1 logical row', () {
      const cutout = PixelBoxCutout(left: 2, width: 10);
      expect(cutout.height, 1);
    });

    test('equality considers all fields', () {
      const a = PixelBoxCutout(left: 2, width: 10, height: 2);
      const b = PixelBoxCutout(left: 2, width: 10, height: 2);
      const c = PixelBoxCutout(left: 3, width: 10, height: 2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('PixelShapePainter.shouldRepaint', () {
    const style = PixelShapeStyle(
      corners: PixelCorners.sharp,
      fillColor: Color(0xFFFF0000),
    );

    test('repaints when labelCutout changes', () {
      final a = PixelShapePainter(
        logicalWidth: 20,
        logicalHeight: 10,
        style: style,
      );
      final b = PixelShapePainter(
        logicalWidth: 20,
        logicalHeight: 10,
        style: style,
        labelCutout: const PixelBoxCutout(left: 2, width: 6),
      );
      expect(b.shouldRepaint(a), isTrue);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('does not repaint when cutout identical', () {
      final a = PixelShapePainter(
        logicalWidth: 20,
        logicalHeight: 10,
        style: style,
        labelCutout: const PixelBoxCutout(left: 2, width: 6),
      );
      final b = PixelShapePainter(
        logicalWidth: 20,
        logicalHeight: 10,
        style: style,
        labelCutout: const PixelBoxCutout(left: 2, width: 6),
      );
      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
