import 'package:flutter/widgets.dart';

import 'package:pixel_ui/src/pixel_shape_painter.dart';
import 'package:pixel_ui/src/pixel_style.dart';

/// Base pixel-shape container.
///
/// Accepts any [child] widget. If only [width] or [height] is given, the other
/// is computed from `logicalWidth / logicalHeight`. If neither is given,
/// defaults to logical size × 4.
class PixelBox extends StatelessWidget {
  final int logicalWidth;
  final int logicalHeight;
  final PixelShapeStyle style;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  final Widget? child;

  const PixelBox({
    super.key,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.style,
    this.width,
    this.height,
    this.padding,
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = logicalWidth / logicalHeight;
    final (w, h) = _resolveSize(ratio);

    final shadow = style.shadow;
    final sox = shadow?.offset.dx.abs() ?? 0;
    final soy = shadow?.offset.dy.abs() ?? 0;
    final perPxW = w / logicalWidth;
    final perPxH = h / logicalHeight;
    final totalW = w + sox * perPxW;
    final totalH = h + soy * perPxH;

    return SizedBox(
      width: totalW,
      height: totalH,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PixelShapePainter(
                logicalWidth: logicalWidth,
                logicalHeight: logicalHeight,
                style: style,
              ),
              isComplex: style.texture != null,
              willChange: false,
            ),
          ),
          if (child != null)
            Positioned(
              left: shadow != null && shadow.offset.dx < 0 ? sox * perPxW : 0,
              top: shadow != null && shadow.offset.dy < 0 ? soy * perPxH : 0,
              width: w,
              height: h,
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: Align(alignment: alignment, child: child),
              ),
            ),
        ],
      ),
    );
  }

  (double, double) _resolveSize(double ratio) {
    if (width != null && height != null) return (width!, height!);
    if (width != null) return (width!, width! / ratio);
    if (height != null) return (height! * ratio, height!);
    return (logicalWidth * 4.0, logicalHeight * 4.0);
  }
}
