import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:pixel_ui/src/pixel_shape_painter.dart';
import 'package:pixel_ui/src/pixel_style.dart';
import 'package:pixel_ui/src/pixel_theme.dart';

/// Base pixel-shape container.
///
/// Accepts any [child] widget. If only [width] or [height] is given, the other
/// is computed from `logicalWidth / logicalHeight`. If neither is given,
/// defaults to logical size × 4.
///
/// When [style] is omitted, falls back to `PixelBoxTheme.style` supplied via
/// [pixelUiTheme]. Asserts if neither is available.
///
/// A custom [PixelShapePainterBuilder] can replace the default
/// [PixelShapePainter]; precedence is [painter] prop > `PixelBoxTheme.painter`
/// > built-in default.
///
/// Supplying [label] paints the widget over the top border with a
/// painter-level carve-out — the classic `[ TITLE ]━━━━━` look.
class PixelBox extends StatefulWidget {
  final int logicalWidth;
  final int logicalHeight;
  final PixelShapeStyle? style;

  /// Optional override for the painter builder. Takes precedence over
  /// `PixelBoxTheme.painter`.
  final PixelShapePainterBuilder? painter;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  /// Widget overlaid on the top border, with a carve-out behind it.
  final Widget? label;

  /// Horizontal offset from the left edge, in logical-pixel units, where the
  /// label's carve-out and visual start.
  final int labelLeftInset;

  final Widget? child;

  const PixelBox({
    super.key,
    required this.logicalWidth,
    required this.logicalHeight,
    this.style,
    this.painter,
    this.width,
    this.height,
    this.padding,
    this.alignment = Alignment.center,
    this.label,
    this.labelLeftInset = 2,
    this.child,
  });

  @override
  State<PixelBox> createState() => _PixelBoxState();
}

class _PixelBoxState extends State<PixelBox> {
  Size? _labelSize;

  @override
  void didUpdateWidget(covariant PixelBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label == null) _labelSize = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme<PixelBoxTheme>();
    final resolved = widget.style ?? theme?.style;
    assert(
      resolved != null,
      'PixelBox requires a `style` prop or a `PixelBoxTheme.style` registered '
      'via `pixelUiTheme(...)` on an ancestor Theme/MaterialApp.',
    );
    final shapeStyle = resolved!;
    final builder = widget.painter ?? theme?.painter ?? _defaultPainterBuilder;

    final ratio = widget.logicalWidth / widget.logicalHeight;
    final (w, h) = _resolveSize(ratio);

    final shadow = shapeStyle.shadow;
    final sox = shadow?.offset.dx.abs() ?? 0;
    final soy = shadow?.offset.dy.abs() ?? 0;
    final perPxW = w / widget.logicalWidth;
    final perPxH = h / widget.logicalHeight;
    final totalW = w + sox * perPxW;
    final totalH = h + soy * perPxH;

    final cutout = _buildCutout(perPxW);
    final contentLeft =
        shadow != null && shadow.offset.dx < 0 ? sox * perPxW : 0.0;
    final contentTop =
        shadow != null && shadow.offset.dy < 0 ? soy * perPxH : 0.0;

    return SizedBox(
      width: totalW,
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: builder(
                logicalWidth: widget.logicalWidth,
                logicalHeight: widget.logicalHeight,
                style: shapeStyle,
                labelCutout: cutout,
              ),
              isComplex: shapeStyle.texture != null,
              willChange: false,
            ),
          ),
          if (widget.child != null)
            Positioned(
              left: contentLeft,
              top: contentTop,
              width: w,
              height: h,
              child: Padding(
                padding: widget.padding ?? EdgeInsets.zero,
                child: Align(
                  alignment: widget.alignment,
                  child: widget.child,
                ),
              ),
            ),
          if (widget.label != null)
            Positioned(
              left: contentLeft + widget.labelLeftInset * perPxW,
              top: contentTop - (_labelSize?.height ?? 0) / 2,
              child: _MeasureSize(
                onChange: _handleLabelSize,
                child: widget.label!,
              ),
            ),
        ],
      ),
    );
  }

  void _handleLabelSize(Size size) {
    if (_labelSize == size) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _labelSize = size);
    });
  }

  PixelBoxCutout? _buildCutout(double perPxW) {
    if (widget.label == null) return null;
    final measured = _labelSize;
    if (measured == null) return null;
    final widthLogical = (measured.width / perPxW).ceil();
    if (widthLogical <= 0) return null;
    return PixelBoxCutout(
      left: widget.labelLeftInset,
      width: widthLogical,
    );
  }

  (double, double) _resolveSize(double ratio) {
    if (widget.width != null && widget.height != null) {
      return (widget.width!, widget.height!);
    }
    if (widget.width != null) return (widget.width!, widget.width! / ratio);
    if (widget.height != null) return (widget.height! * ratio, widget.height!);
    return (widget.logicalWidth * 4.0, widget.logicalHeight * 4.0);
  }
}

CustomPainter _defaultPainterBuilder({
  required int logicalWidth,
  required int logicalHeight,
  required PixelShapeStyle style,
  PixelBoxCutout? labelCutout,
}) {
  return PixelShapePainter(
    logicalWidth: logicalWidth,
    logicalHeight: logicalHeight,
    style: style,
    labelCutout: labelCutout,
  );
}

/// Single-child render proxy that notifies when its child's size changes.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required Widget child})
      : super(child: child);

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderBox(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderBox renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderBox extends RenderProxyBox {
  _MeasureSizeRenderBox(this.onChange);

  ValueChanged<Size> onChange;
  Size? _prev;

  @override
  void performLayout() {
    super.performLayout();
    final s = child?.size ?? Size.zero;
    if (_prev == s) return;
    _prev = s;
    onChange(s);
  }
}
