import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

PixelShapePainter _painter({
  int logicalWidth = 10,
  int logicalHeight = 10,
  PixelShapeStyle style = const PixelShapeStyle(
    corners: PixelCorners.sharp,
    fillColor: Color(0xFFFF0000),
  ),
}) {
  return PixelShapePainter(
    logicalWidth: logicalWidth,
    logicalHeight: logicalHeight,
    style: style,
  );
}

void main() {
  group('PixelShapePainter constructor asserts', () {
    test('logicalWidth must be positive', () {
      expect(() => _painter(logicalWidth: 0), throwsAssertionError);
      expect(() => _painter(logicalWidth: -1), throwsAssertionError);
    });

    test('logicalHeight must be positive', () {
      expect(() => _painter(logicalHeight: 0), throwsAssertionError);
      expect(() => _painter(logicalHeight: -1), throwsAssertionError);
    });

    test('positive dims pass', () {
      expect(() => _painter(logicalWidth: 1, logicalHeight: 1), returnsNormally);
    });
  });

  group('PixelShapePainter.paint asserts (cross-field invariants)', () {
    // Drives paint() against a no-op recording canvas to trigger debug asserts
    // that reference style.corners, which cannot live in the const constructor.
    const size = Size(40, 40);

    test('corner stairs must fit within logicalHeight', () {
      // topInsetRows=3 + bottomInsetRows=3 > logicalHeight=5
      final painter = _painter(
        logicalWidth: 10,
        logicalHeight: 5,
        style: const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: Color(0xFFFF0000),
        ),
      );
      expect(
        () => painter.paint(_NoopCanvas(), size),
        throwsAssertionError,
      );
    });

    test('corner stairs exactly fitting logicalHeight pass', () {
      // topInsetRows=3 + bottomInsetRows=3 == logicalHeight=6
      final painter = _painter(
        logicalWidth: 10,
        logicalHeight: 6,
        style: const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: Color(0xFFFF0000),
        ),
      );
      expect(() => painter.paint(_NoopCanvas(), size), returnsNormally);
    });
  });

  group('PixelShapeStyle constructor asserts', () {
    test('borderWidth cannot be negative', () {
      expect(
        () => PixelShapeStyle(
          corners: PixelCorners.sharp,
          fillColor: const Color(0xFFFF0000),
          borderWidth: -1,
        ),
        throwsAssertionError,
      );
    });
  });

  group('PixelTexture constructor asserts', () {
    test('size must be >= 1', () {
      expect(
        () => PixelTexture(color: const Color(0xFFFFFFFF), size: 0),
        throwsAssertionError,
      );
      expect(
        () => PixelTexture(color: const Color(0xFFFFFFFF), size: -1),
        throwsAssertionError,
      );
    });

    test('density must be in [0, 1]', () {
      expect(
        () => PixelTexture(color: const Color(0xFFFFFFFF), density: -0.1),
        throwsAssertionError,
      );
      expect(
        () => PixelTexture(color: const Color(0xFFFFFFFF), density: 1.1),
        throwsAssertionError,
      );
    });

    test('density boundaries 0.0 and 1.0 pass', () {
      expect(
        () => PixelTexture(color: const Color(0xFFFFFFFF), density: 0),
        returnsNormally,
      );
      expect(
        () => PixelTexture(color: const Color(0xFFFFFFFF), density: 1),
        returnsNormally,
      );
    });
  });
}

// Minimal canvas stub — paint() only needs drawRect; asserts fire before any
// drawing work in the corner-overlap case.
class _NoopCanvas implements Canvas {
  @override
  void drawRect(Rect rect, Paint paint) {}

  @override
  noSuchMethod(Invocation invocation) {
    throw UnsupportedError('${invocation.memberName} not mocked');
  }
}
