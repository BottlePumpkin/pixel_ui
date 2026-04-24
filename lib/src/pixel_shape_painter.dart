import 'package:flutter/rendering.dart';

import 'package:pixel_ui/src/pixel_style.dart';

/// Low-level CustomPainter for pixel shapes.
///
/// - Takes a single [PixelShapeStyle] for `shouldRepaint` optimization.
/// - [logicalWidth]/[logicalHeight] is the "design-basis pixel count"; actual
///   render size auto-scales to match the composed canvas size.
/// - Texture uses a deterministic LCG (1664525, 1013904223) so identical
///   settings always produce the same pattern across platforms/builds.
class PixelShapePainter extends CustomPainter {
  final int logicalWidth;
  final int logicalHeight;
  final PixelShapeStyle style;

  const PixelShapePainter({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = style.shadow;
    final sox = shadow?.offset.dx.toInt() ?? 0;
    final soy = shadow?.offset.dy.toInt() ?? 0;

    final totalW = logicalWidth + sox.abs();
    final px = size.width / totalW;
    final baseX = sox < 0 ? -sox : 0;
    final baseY = soy < 0 ? -soy : 0;

    if (shadow != null) {
      if (shadow.style == PixelShadowStyle.stipple) {
        _drawStippleShape(
          canvas,
          Paint()
            ..color = shadow.color
            ..isAntiAlias = false,
          baseX + sox,
          baseY + soy,
          logicalWidth,
          logicalHeight,
          px,
        );
      } else {
        _drawShape(
          canvas,
          Paint()
            ..color = shadow.color
            ..isAntiAlias = false,
          baseX + sox,
          baseY + soy,
          logicalWidth,
          logicalHeight,
          px,
        );
      }
    }

    if (style.borderColor != null && style.borderWidth > 0) {
      _drawShape(
        canvas,
        Paint()
          ..color = style.borderColor!
          ..isAntiAlias = false,
        baseX,
        baseY,
        logicalWidth,
        logicalHeight,
        px,
      );
    }

    final inset = (style.borderColor != null) ? style.borderWidth : 0;
    final fillW = logicalWidth - inset * 2;
    final fillH = logicalHeight - inset * 2;
    _drawShape(
      canvas,
      Paint()
        ..color = style.fillColor
        ..isAntiAlias = false,
      baseX + inset,
      baseY + inset,
      fillW,
      fillH,
      px,
    );

    final tex = style.texture;
    if (tex != null && tex.density > 0) {
      _drawTexture(
        canvas,
        baseX + inset,
        baseY + inset,
        fillW,
        fillH,
        px,
        tex,
      );
    }
  }

  void _drawShape(
    Canvas canvas,
    Paint paint,
    int offsetX,
    int offsetY,
    int w,
    int h,
    double px,
  ) {
    final c = style.corners;
    final topMax = c.topInsetRows;
    final bottomMax = c.bottomInsetRows;

    for (int i = 0; i < topMax; i++) {
      final lIns = i < c.tl.length ? c.tl[i] : 0;
      final rIns = i < c.tr.length ? c.tr[i] : 0;
      final rowW = w - lIns - rIns;
      if (rowW > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            (offsetX + lIns) * px,
            (offsetY + i) * px,
            rowW * px,
            px,
          ),
          paint,
        );
      }
    }

    final midH = h - topMax - bottomMax;
    if (midH > 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          offsetX * px,
          (offsetY + topMax) * px,
          w * px,
          midH * px,
        ),
        paint,
      );
    }

    for (int i = 0; i < bottomMax; i++) {
      final row = bottomMax - 1 - i;
      final lIns = row < c.bl.length ? c.bl[row] : 0;
      final rIns = row < c.br.length ? c.br[row] : 0;
      final rowW = w - lIns - rIns;
      if (rowW > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            (offsetX + lIns) * px,
            (offsetY + h - bottomMax + i) * px,
            rowW * px,
            px,
          ),
          paint,
        );
      }
    }
  }

  void _drawStippleShape(
    Canvas canvas,
    Paint paint,
    int offsetX,
    int offsetY,
    int w,
    int h,
    double px,
  ) {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if ((x + y).isOdd) continue;
        if (!_isInside(x, y, w, h)) continue;
        canvas.drawRect(
          Rect.fromLTWH((offsetX + x) * px, (offsetY + y) * px, px, px),
          paint,
        );
      }
    }
  }

  void _drawTexture(
    Canvas canvas,
    int offsetX,
    int offsetY,
    int w,
    int h,
    double px,
    PixelTexture tex,
  ) {
    final paint = Paint()
      ..color = tex.color
      ..isAntiAlias = false;
    final size = tex.size;
    int state = tex.seed & 0xFFFFFFFF;

    for (int y = 0; y < h; y += size) {
      for (int x = 0; x < w; x += size) {
        state = (state * 1664525 + 1013904223) & 0xFFFFFFFF;
        if (!_isInside(x, y, w, h)) continue;
        final r = state / 0xFFFFFFFF;
        if (r < tex.density) {
          canvas.drawRect(
            Rect.fromLTWH(
              (offsetX + x) * px,
              (offsetY + y) * px,
              size * px,
              size * px,
            ),
            paint,
          );
        }
      }
    }
  }

  bool _isInside(int x, int y, int w, int h) {
    if (x < 0 || y < 0 || x >= w || y >= h) return false;
    final c = style.corners;
    final topMax = c.topInsetRows;
    final bottomMax = c.bottomInsetRows;

    if (y < topMax) {
      final lIns = y < c.tl.length ? c.tl[y] : 0;
      final rIns = y < c.tr.length ? c.tr[y] : 0;
      return x >= lIns && x < w - rIns;
    }
    if (y >= h - bottomMax) {
      final row = h - 1 - y;
      final lIns = row < c.bl.length ? c.bl[row] : 0;
      final rIns = row < c.br.length ? c.br[row] : 0;
      return x >= lIns && x < w - rIns;
    }
    return true;
  }

  @override
  bool shouldRepaint(covariant PixelShapePainter old) =>
      old.style != style ||
      old.logicalWidth != logicalWidth ||
      old.logicalHeight != logicalHeight;
}
