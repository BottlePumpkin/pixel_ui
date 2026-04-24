// Repro for #34 — PixelTexture cells must not extend past the shape's
// painted bounds. Uses a recording canvas to inspect every drawRect.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

class _RecordingCanvas implements Canvas {
  final List<Rect> rects = [];

  @override
  void drawRect(Rect rect, Paint paint) => rects.add(rect);

  @override
  noSuchMethod(Invocation invocation) {
    throw UnsupportedError('${invocation.memberName} not mocked');
  }
}

void main() {
  test('texture cells stay inside shape bounds when cell size > logical dim',
      () {
    // logical 5x5, canvas 50x50 → px = 10. Shape bounds in canvas coords:
    // (0, 0) to (50, 50). Texture cell size=10 logical = 100 px — without
    // clamping, every drawn cell overflows by 50px in each dimension.
    const painter = PixelShapePainter(
      logicalWidth: 5,
      logicalHeight: 5,
      style: PixelShapeStyle(
        corners: PixelCorners.sharp,
        fillColor: ui.Color(0xFFDDCC88),
        texture: PixelTexture(
          color: ui.Color(0xFF553311),
          density: 1.0, // force every cell to paint
          size: 10,
          seed: 7,
        ),
      ),
    );

    final canvas = _RecordingCanvas();
    painter.paint(canvas as Canvas, const ui.Size(50, 50));

    // Shape bounds (no shadow, no border inset): (0, 0, 50, 50).
    const shapeBounds = Rect.fromLTWH(0, 0, 50, 50);
    for (final r in canvas.rects) {
      expect(shapeBounds.contains(r.topLeft), isTrue,
          reason: 'rect $r starts outside shape');
      expect(r.right <= shapeBounds.right + 0.0001, isTrue,
          reason: 'rect $r overflows right edge ${shapeBounds.right}');
      expect(r.bottom <= shapeBounds.bottom + 0.0001, isTrue,
          reason: 'rect $r overflows bottom edge ${shapeBounds.bottom}');
    }
  });
}
