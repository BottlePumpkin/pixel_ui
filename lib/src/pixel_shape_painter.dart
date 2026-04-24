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

  /// Optional rectangle to skip in the border + fill passes. The shadow pass
  /// is unaffected. Used internally by `PixelBox.label`.
  final PixelBoxCutout? labelCutout;

  const PixelShapePainter({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.style,
    this.labelCutout,
  })  : assert(logicalWidth > 0,
            'logicalWidth must be positive (got $logicalWidth)'),
        assert(logicalHeight > 0,
            'logicalHeight must be positive (got $logicalHeight)');

  @override
  void paint(Canvas canvas, Size size) {
    // Cross-field invariant: corner stairs from top + bottom cannot collide.
    // When they do, the top and bottom draw loops silently overpaint shared
    // rows with different insets, corrupting the outline. See #33.
    assert(
      style.corners.topInsetRows + style.corners.bottomInsetRows <=
          logicalHeight,
      'Corner stairs overflow logicalHeight: '
      'topInsetRows=${style.corners.topInsetRows} + '
      'bottomInsetRows=${style.corners.bottomInsetRows} > '
      'logicalHeight=$logicalHeight',
    );

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
        cutout: _cutoutFor(inset: 0),
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
      cutout: _cutoutFor(inset: inset),
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
    double px, {
    PixelBoxCutout? cutout,
  }) {
    final c = style.corners;
    final topMax = c.topInsetRows;
    final bottomMax = c.bottomInsetRows;

    for (int i = 0; i < topMax; i++) {
      final lIns = i < c.tl.length ? c.tl[i] : 0;
      final rIns = i < c.tr.length ? c.tr[i] : 0;
      _drawRow(canvas, paint, offsetX, offsetY, i, lIns, w - rIns, px, cutout);
    }

    final midH = h - topMax - bottomMax;
    for (int i = 0; i < midH; i++) {
      _drawRow(canvas, paint, offsetX, offsetY, topMax + i, 0, w, px, cutout);
    }

    for (int i = 0; i < bottomMax; i++) {
      final row = bottomMax - 1 - i;
      final lIns = row < c.bl.length ? c.bl[row] : 0;
      final rIns = row < c.br.length ? c.br[row] : 0;
      _drawRow(
        canvas,
        paint,
        offsetX,
        offsetY,
        h - bottomMax + i,
        lIns,
        w - rIns,
        px,
        cutout,
      );
    }
  }

  void _drawRow(
    Canvas canvas,
    Paint paint,
    int offsetX,
    int offsetY,
    int rowY,
    int xStart,
    int xEnd,
    double px,
    PixelBoxCutout? cutout,
  ) {
    if (xEnd <= xStart) return;

    if (cutout == null || rowY >= cutout.height) {
      _drawSegment(canvas, paint, offsetX + xStart, offsetY + rowY,
          xEnd - xStart, px);
      return;
    }

    final cutLeft = cutout.left.clamp(xStart, xEnd);
    final cutRight = (cutout.left + cutout.width).clamp(xStart, xEnd);
    if (cutLeft > xStart) {
      _drawSegment(canvas, paint, offsetX + xStart, offsetY + rowY,
          cutLeft - xStart, px);
    }
    if (xEnd > cutRight) {
      _drawSegment(canvas, paint, offsetX + cutRight, offsetY + rowY,
          xEnd - cutRight, px);
    }
  }

  void _drawSegment(
    Canvas canvas,
    Paint paint,
    int x,
    int y,
    int w,
    double px,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(x * px, y * px, w * px, px),
      paint,
    );
  }

  /// Rebases [labelCutout] from shape-logical coords into the pass-local coords
  /// of a draw pass whose shape is inset by [inset] rows/columns on each side.
  /// Returns null when the cutout is fully consumed by the inset (e.g. the
  /// border already covers all cutout rows).
  PixelBoxCutout? _cutoutFor({required int inset}) {
    final c = labelCutout;
    if (c == null) return null;
    final localHeight = c.height - inset;
    if (localHeight <= 0) return null;
    return PixelBoxCutout(
      left: c.left - inset,
      width: c.width,
      height: localHeight,
    );
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
      old.logicalHeight != logicalHeight ||
      old.labelCutout != labelCutout;
}
