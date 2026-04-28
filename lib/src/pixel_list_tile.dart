import 'package:flutter/material.dart';

import 'package:pixel_ui/src/pixel_box.dart';
import 'package:pixel_ui/src/pixel_style.dart';
import 'package:pixel_ui/src/pixel_theme.dart';

/// A pixel-styled row layout for settings / profile / menu screens.
///
/// Stretches to the parent's full width (use inside a vertical layout that
/// constrains horizontal space — `Column`, `ListView`, etc.). Vertical
/// size = `logicalHeight × 4` dp by default.
///
/// Slots are composed left → right: `leading?` · `Expanded(title + subtitle?)` ·
/// `trailing?`, with `slotGap` between adjacent slots.
///
/// `onTap == null` renders an informational row (no gesture, no button
/// semantics). `onTap != null` adds press feedback (paints `pressedStyle` and
/// slides children by `pressChildOffset`) and exposes `Semantics(button: true)`.
///
/// `enabled == false` is independent of `onTap` — controls visual only:
/// paints `disabledStyle` if provided, else `style` rendered at 50% opacity.
class PixelListTile extends StatefulWidget {
  const PixelListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.style,
    this.pressedStyle,
    this.disabledStyle,
    this.contentPadding,
    this.slotGap,
    this.logicalWidth = 80,
    this.logicalHeight = 14,
    this.pressChildOffset = const Offset(0, 1),
    this.semanticsLabel,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final PixelShapeStyle? style;
  final PixelShapeStyle? pressedStyle;
  final PixelShapeStyle? disabledStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double? slotGap;
  final int logicalWidth;
  final int logicalHeight;
  final Offset pressChildOffset;
  final String? semanticsLabel;

  @override
  State<PixelListTile> createState() => _PixelListTileState();
}

class _PixelListTileState extends State<PixelListTile> {
  static const _defaultPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const _defaultSlotGap = 12.0;

  bool _pressed = false;

  bool get _interactive => widget.onTap != null && widget.enabled;

  void _setPressed(bool v) {
    if (!_interactive) return;
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme<PixelListTileTheme>();
    final style = widget.style ?? theme?.style;
    assert(
      style != null,
      'PixelListTile requires a `style` prop or a `PixelListTileTheme.style` '
      'registered via `pixelUiTheme(...)` on an ancestor Theme/MaterialApp.',
    );
    final pressedStyle = widget.pressedStyle ?? theme?.pressedStyle;
    final disabled = widget.disabledStyle ?? theme?.disabledStyle;

    final currentStyle = _resolveCurrentStyle(style!, pressedStyle, disabled);
    final opacity = !widget.enabled && disabled == null ? 0.5 : 1.0;

    return LayoutBuilder(builder: (context, constraints) {
      final padding =
          widget.contentPadding ?? theme?.contentPadding ?? _defaultPadding;

      Widget tile = PixelBox(
        style: currentStyle,
        logicalWidth: widget.logicalWidth,
        logicalHeight: widget.logicalHeight,
        width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        padding: padding,
        alignment: Alignment.centerLeft,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          offset: _pressed
              ? Offset(
                  widget.pressChildOffset.dx /
                      widget.logicalHeight.toDouble(),
                  widget.pressChildOffset.dy /
                      widget.logicalHeight.toDouble(),
                )
              : Offset.zero,
          child: _buildRow(theme),
        ),
      );

      if (opacity < 1.0) {
        tile = Opacity(opacity: opacity, child: tile);
      }

      if (widget.onTap == null) {
        return Semantics(
          container: true,
          label: widget.semanticsLabel,
          excludeSemantics: widget.semanticsLabel != null,
          child: tile,
        );
      }

      return Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.semanticsLabel,
        excludeSemantics: widget.semanticsLabel != null,
        onTap: widget.enabled ? widget.onTap : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _interactive ? widget.onTap : null,
          child: tile,
        ),
      );
    });
  }

  PixelShapeStyle _resolveCurrentStyle(
    PixelShapeStyle normal,
    PixelShapeStyle? pressed,
    PixelShapeStyle? disabled,
  ) {
    if (!widget.enabled && disabled != null) return disabled;
    if (_pressed && pressed != null) return pressed;
    return normal;
  }

  Widget _buildRow(PixelListTileTheme? theme) {
    final gap = widget.slotGap ?? theme?.slotGap ?? _defaultSlotGap;

    final children = <Widget>[];
    if (widget.leading != null) {
      children.add(widget.leading!);
      children.add(SizedBox(width: gap));
    }
    children.add(Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.title,
          if (widget.subtitle != null) ...[
            const SizedBox(height: 2),
            widget.subtitle!,
          ],
        ],
      ),
    ));
    if (widget.trailing != null) {
      children.add(SizedBox(width: gap));
      children.add(widget.trailing!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
