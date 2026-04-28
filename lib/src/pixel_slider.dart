import 'package:flutter/material.dart';

import 'package:pixel_ui/src/pixel_box.dart';
import 'package:pixel_ui/src/pixel_style.dart';
import 'package:pixel_ui/src/pixel_theme.dart';

/// A pixel-styled value slider (continuous or discrete).
///
/// Drop-in replacement for Material `Slider` inside a pixel-themed app.
/// Renders a track, value-clipped fill, and a positioned thumb that anchors
/// `value == min` to the left edge and `value == max` to the right edge.
///
/// Tap and horizontal drag both update `value` via [onChanged]. Keyboard
/// (Arrow keys + PageUp/Down) adjusts `value` while focused. Set [divisions]
/// to snap to evenly-spaced steps, or leave null for continuous.
///
/// `enabled == false` blocks tap/drag/keyboard and paints [disabledStyle]
/// (track only) if provided, else wraps the entire visual at 50% opacity.
class PixelSlider extends StatefulWidget {
  const PixelSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackStyle,
    this.fillStyle,
    this.thumbStyle,
    this.disabledStyle,
    this.trackLogicalWidth = 80,
    this.trackLogicalHeight = 4,
    this.thumbLogicalSize = 8,
    this.keyboardStep,
    this.pageStep,
    this.semanticsLabel,
    this.semanticsValueText,
    this.focusNode,
    this.autofocus = false,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final double min;
  final double max;
  final int? divisions;
  final PixelShapeStyle? trackStyle;
  final PixelShapeStyle? fillStyle;
  final PixelShapeStyle? thumbStyle;
  final PixelShapeStyle? disabledStyle;
  final int trackLogicalWidth;
  final int trackLogicalHeight;
  final int thumbLogicalSize;
  final double? keyboardStep;
  final double? pageStep;
  final String? semanticsLabel;
  final String Function(double value)? semanticsValueText;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<PixelSlider> createState() => _PixelSliderState();
}

class _PixelSliderState extends State<PixelSlider> {
  static const _logicalToDp = 4.0;

  double get _ratio {
    final span = widget.max - widget.min;
    if (span <= 0) return 0;
    return ((widget.value - widget.min) / span).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme<PixelSliderTheme>();
    final track = widget.trackStyle ?? theme?.trackStyle;
    final fill = widget.fillStyle ?? theme?.fillStyle;
    final thumb = widget.thumbStyle ?? theme?.thumbStyle;
    assert(
      track != null && fill != null && thumb != null,
      'PixelSlider requires `trackStyle`, `fillStyle`, and `thumbStyle` either '
      'as props or as `PixelSliderTheme.<field>` registered via '
      '`pixelUiTheme(...)` on an ancestor Theme/MaterialApp.',
    );

    final thumbDp = widget.thumbLogicalSize * _logicalToDp;
    final trackDpH = widget.trackLogicalHeight * _logicalToDp;
    final outerDpH = thumbDp > trackDpH ? thumbDp : trackDpH;
    final trackTopOffset = (outerDpH - trackDpH) / 2;
    final thumbTopOffset = (outerDpH - thumbDp) / 2;

    return LayoutBuilder(builder: (context, constraints) {
      final trackDpW =
          constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
      final thumbLeft = (trackDpW - thumbDp) * _ratio;
      // Fill spans from track left to thumb's right edge.
      final fillDpW = thumbLeft + thumbDp;

      return SizedBox(
        width: trackDpW,
        height: outerDpH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: trackTopOffset,
              width: trackDpW,
              height: trackDpH,
              child: PixelBox(
                style: track!,
                logicalWidth: widget.trackLogicalWidth,
                logicalHeight: widget.trackLogicalHeight,
                width: trackDpW,
                height: trackDpH,
              ),
            ),
            Positioned(
              left: 0,
              top: trackTopOffset,
              width: fillDpW,
              height: trackDpH,
              child: PixelBox(
                style: fill!,
                logicalWidth: widget.trackLogicalWidth,
                logicalHeight: widget.trackLogicalHeight,
                width: fillDpW,
                height: trackDpH,
              ),
            ),
            Positioned(
              left: thumbLeft,
              top: thumbTopOffset,
              width: thumbDp,
              height: thumbDp,
              child: PixelBox(
                style: thumb!,
                logicalWidth: widget.thumbLogicalSize,
                logicalHeight: widget.thumbLogicalSize,
                width: thumbDp,
                height: thumbDp,
              ),
            ),
          ],
        ),
      );
    });
  }
}
