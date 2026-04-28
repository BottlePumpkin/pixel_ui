import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    final disabled = widget.disabledStyle ?? theme?.disabledStyle;
    final trackEffective =
        !widget.enabled && disabled != null ? disabled : track!;
    final opacity =
        !widget.enabled && disabled == null ? 0.5 : 1.0;

    final thumbDp = widget.thumbLogicalSize * _logicalToDp;
    final trackDpH = widget.trackLogicalHeight * _logicalToDp;
    final outerDpH = thumbDp > trackDpH ? thumbDp : trackDpH;
    final trackTopOffset = (outerDpH - trackDpH) / 2;
    final thumbTopOffset = (outerDpH - thumbDp) / 2;

    final tree = LayoutBuilder(builder: (context, constraints) {
      final trackDpW =
          constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
      final thumbLeft = (trackDpW - thumbDp) * _ratio;
      final fillDpW = thumbLeft + thumbDp;

      final visual = SizedBox(
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
                style: trackEffective,
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

      final gd = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _interactive
            ? (d) => _setValueFromDx(d.localPosition.dx, trackDpW, thumbDp)
            : null,
        onHorizontalDragStart: _interactive
            ? (d) => _setValueFromDx(d.localPosition.dx, trackDpW, thumbDp)
            : null,
        onHorizontalDragUpdate: _interactive
            ? (d) => _setValueFromDx(d.localPosition.dx, trackDpW, thumbDp)
            : null,
        child: visual,
      );

      Widget focusable = FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: _interactive && widget.autofocus,
        enabled: _interactive,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowLeft): _DecreaseSmallIntent(),
          SingleActivator(LogicalKeyboardKey.arrowDown): _DecreaseSmallIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight):
              _IncreaseSmallIntent(),
          SingleActivator(LogicalKeyboardKey.arrowUp): _IncreaseSmallIntent(),
          SingleActivator(LogicalKeyboardKey.pageDown): _DecreaseLargeIntent(),
          SingleActivator(LogicalKeyboardKey.pageUp): _IncreaseLargeIntent(),
        },
        actions: {
          _DecreaseSmallIntent: CallbackAction<_DecreaseSmallIntent>(
            onInvoke: (_) {
              _adjust(-_keyboardStep);
              return null;
            },
          ),
          _IncreaseSmallIntent: CallbackAction<_IncreaseSmallIntent>(
            onInvoke: (_) {
              _adjust(_keyboardStep);
              return null;
            },
          ),
          _DecreaseLargeIntent: CallbackAction<_DecreaseLargeIntent>(
            onInvoke: (_) {
              _adjust(-_pageStep);
              return null;
            },
          ),
          _IncreaseLargeIntent: CallbackAction<_IncreaseLargeIntent>(
            onInvoke: (_) {
              _adjust(_pageStep);
              return null;
            },
          ),
        },
        child: gd,
      );

      if (opacity < 1.0) {
        focusable = Opacity(opacity: opacity, child: focusable);
      }
      return focusable;
    });

    final formatted = _formatValue(widget.value);
    final preview = _formatValue(
      (widget.value + _keyboardStep).clamp(widget.min, widget.max),
    );
    final reverse = _formatValue(
      (widget.value - _keyboardStep).clamp(widget.min, widget.max),
    );

    return Semantics(
      slider: true,
      enabled: _interactive,
      label: widget.semanticsLabel,
      value: formatted,
      increasedValue: preview,
      decreasedValue: reverse,
      onIncrease: _interactive ? () => _adjust(_keyboardStep) : null,
      onDecrease: _interactive ? () => _adjust(-_keyboardStep) : null,
      child: tree,
    );
  }

  String _formatValue(double v) {
    final formatter = widget.semanticsValueText;
    if (formatter != null) return formatter(v);
    if (widget.min == 0.0 && widget.max == 1.0) {
      return '${(v * 100).round()}%';
    }
    return v.toString();
  }

  bool get _interactive => widget.enabled && widget.onChanged != null;

  /// Maps an x-coordinate inside the slider widget to a value in [min, max]
  /// using the iOS-style geometry: thumb anchors `value == min` to left=0
  /// and `value == max` to left = trackW − thumbW. Dragging beyond either
  /// edge clamps to the bounds.
  void _setValueFromDx(double dx, double trackW, double thumbW) {
    final usable = trackW - thumbW;
    if (usable <= 0) return;
    final ratio = ((dx - thumbW / 2) / usable).clamp(0.0, 1.0);
    var raw = widget.min + ratio * (widget.max - widget.min);
    raw = _maybeSnap(raw);
    if (raw == widget.value) return;
    widget.onChanged?.call(raw);
  }

  /// Snaps `v` to the nearest division step when `divisions != null`. With
  /// `divisions = N`, the valid steps are `min + i * (max - min) / N` for
  /// `i in 0..N`.
  double _maybeSnap(double v) {
    final n = widget.divisions;
    if (n == null || n <= 0) return v;
    final span = widget.max - widget.min;
    if (span == 0) return widget.min;
    final stepSize = span / n;
    final stepIndex = ((v - widget.min) / stepSize).round();
    return widget.min + stepIndex * stepSize;
  }

  double get _defaultKeyboardStep {
    final span = widget.max - widget.min;
    final n = widget.divisions;
    if (n != null && n > 0) return span / n;
    return span / 20;
  }

  double get _defaultPageStep {
    final span = widget.max - widget.min;
    final n = widget.divisions;
    if (n != null && n > 0) {
      final small = span / n;
      final big = span / 10;
      return small > big ? small : big;
    }
    return span / 4;
  }

  double get _keyboardStep => widget.keyboardStep ?? _defaultKeyboardStep;
  double get _pageStep => widget.pageStep ?? _defaultPageStep;

  void _adjust(double delta) {
    if (!_interactive) return;
    final raw = (widget.value + delta).clamp(widget.min, widget.max);
    final snapped = _maybeSnap(raw);
    if (snapped == widget.value) return;
    widget.onChanged?.call(snapped);
  }
}

class _DecreaseSmallIntent extends Intent {
  const _DecreaseSmallIntent();
}

class _IncreaseSmallIntent extends Intent {
  const _IncreaseSmallIntent();
}

class _DecreaseLargeIntent extends Intent {
  const _DecreaseLargeIntent();
}

class _IncreaseLargeIntent extends Intent {
  const _IncreaseLargeIntent();
}
