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
  // ignore: unused_field  — T5 will use this for slot spacing
  static const _defaultSlotGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme<PixelListTileTheme>();
    final style = widget.style ?? theme?.style;
    assert(
      style != null,
      'PixelListTile requires a `style` prop or a `PixelListTileTheme.style` '
      'registered via `pixelUiTheme(...)` on an ancestor Theme/MaterialApp.',
    );

    return LayoutBuilder(builder: (context, constraints) {
      final padding =
          widget.contentPadding ?? theme?.contentPadding ?? _defaultPadding;

      return PixelBox(
        style: style,
        logicalWidth: widget.logicalWidth,
        logicalHeight: widget.logicalHeight,
        width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        padding: padding,
        alignment: Alignment.centerLeft,
        child: widget.title,
      );
    });
  }
}
