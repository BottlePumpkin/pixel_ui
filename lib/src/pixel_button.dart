import 'package:flutter/widgets.dart';

import 'package:pixel_ui/src/pixel_box.dart';
import 'package:pixel_ui/src/pixel_style.dart';

/// Interactive pixel button with optional press-state and disabled-state styles.
///
/// Visuals come from [normalStyle] in the default state, [pressedStyle] when
/// pressed (falling back to [normalStyle] if not provided), and [disabledStyle]
/// when [onPressed] is null (falling back to [normalStyle] rendered at 50%
/// opacity if not provided). The child can be shifted down by
/// [pressChildOffset] while pressed, simulating a button press.
class PixelButton extends StatefulWidget {
  final int logicalWidth;
  final int logicalHeight;

  final PixelShapeStyle normalStyle;

  /// Style to show while pressed. `null` keeps [normalStyle].
  final PixelShapeStyle? pressedStyle;

  /// Style to show when [onPressed] is `null`. `null` keeps [normalStyle]
  /// rendered at 50% opacity (the default dimmed look).
  final PixelShapeStyle? disabledStyle;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  final Widget child;
  final VoidCallback? onPressed;

  /// Offset (in dp) that the child shifts while pressed. `Offset.zero` = no movement.
  final Offset pressChildOffset;

  final bool enableFeedback;

  /// Accessibility label for screen readers.
  final String? semanticsLabel;

  const PixelButton({
    super.key,
    required this.logicalWidth,
    required this.logicalHeight,
    required this.normalStyle,
    this.pressedStyle,
    this.disabledStyle,
    this.width,
    this.height,
    this.padding,
    this.alignment = Alignment.center,
    required this.child,
    this.onPressed,
    this.pressChildOffset = Offset.zero,
    this.enableFeedback = true,
    this.semanticsLabel,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  PixelShapeStyle get _currentStyle {
    if (!_enabled && widget.disabledStyle != null) return widget.disabledStyle!;
    if (_pressed && widget.pressedStyle != null) return widget.pressedStyle!;
    return widget.normalStyle;
  }

  double get _opacity {
    // Only dim when falling back to normalStyle in the disabled state;
    // a custom disabledStyle already carries the author's intent.
    if (!_enabled && widget.disabledStyle == null) return 0.5;
    return 1.0;
  }

  void _setPressed(bool v) {
    if (!_enabled) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticsLabel,
      excludeSemantics: widget.semanticsLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _enabled ? () => widget.onPressed!() : null,
        child: Opacity(
          opacity: _opacity,
          child: PixelBox(
            logicalWidth: widget.logicalWidth,
            logicalHeight: widget.logicalHeight,
            style: _currentStyle,
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            alignment: widget.alignment,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOut,
              offset: _pressed
                  ? Offset(
                      widget.pressChildOffset.dx / widget.logicalHeight.toDouble(),
                      widget.pressChildOffset.dy / widget.logicalHeight.toDouble(),
                    )
                  : Offset.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
