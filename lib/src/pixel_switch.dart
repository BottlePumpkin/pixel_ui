import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pixel_ui/src/pixel_box.dart';
import 'package:pixel_ui/src/pixel_style.dart';
import 'package:pixel_ui/src/pixel_theme.dart';

/// A pixel-styled boolean toggle with a sliding thumb.
///
/// Drop-in replacement for Material `Switch` inside a pixel-themed app.
/// The track style swaps between [onTrackStyle] and [offTrackStyle] based
/// on [value]; the [thumbStyle] is independent of value and slides to the
/// matching side over [animationDuration].
///
/// `onChanged == null` OR `enabled == false` disables the gesture and
/// keyboard but still paints. When `enabled == false`, the widget paints
/// [disabledStyle] if provided, else the active track style at 50% opacity.
class PixelSwitch extends StatefulWidget {
  const PixelSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onTrackStyle,
    this.offTrackStyle,
    this.thumbStyle,
    this.disabledStyle,
    this.trackLogicalWidth = 24,
    this.trackLogicalHeight = 12,
    this.thumbLogicalSize,
    this.thumbInset = 1,
    this.animationDuration = const Duration(milliseconds: 120),
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final PixelShapeStyle? onTrackStyle;
  final PixelShapeStyle? offTrackStyle;
  final PixelShapeStyle? thumbStyle;
  final PixelShapeStyle? disabledStyle;
  final int trackLogicalWidth;
  final int trackLogicalHeight;
  final int? thumbLogicalSize;
  final int thumbInset;
  final Duration animationDuration;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<PixelSwitch> createState() => _PixelSwitchState();
}

class _PixelSwitchState extends State<PixelSwitch> {
  @override
  Widget build(BuildContext context) {
    final theme = context.pixelTheme<PixelSwitchTheme>();
    final on = widget.onTrackStyle ?? theme?.onTrackStyle;
    final off = widget.offTrackStyle ?? theme?.offTrackStyle;
    final thumb = widget.thumbStyle ?? theme?.thumbStyle;
    assert(
      on != null && off != null && thumb != null,
      'PixelSwitch requires `onTrackStyle`, `offTrackStyle`, and `thumbStyle` '
      'either as props or as `PixelSwitchTheme.<field>` registered via '
      '`pixelUiTheme(...)` on an ancestor Theme/MaterialApp.',
    );

    final disabled = widget.disabledStyle ?? theme?.disabledStyle;
    final activeStyle = widget.value ? on! : off!;
    final trackStyle =
        !widget.enabled && disabled != null ? disabled : activeStyle;
    final opacity =
        !widget.enabled && disabled == null ? 0.5 : 1.0;

    final thumbSize = widget.thumbLogicalSize ??
        widget.trackLogicalHeight - 2 * widget.thumbInset;
    const logicalToDp = 4.0;
    final trackDpW = widget.trackLogicalWidth * logicalToDp;
    final trackDpH = widget.trackLogicalHeight * logicalToDp;
    final thumbDp = thumbSize * logicalToDp;
    final insetDp = widget.thumbInset * logicalToDp;
    final onLeft = trackDpW - thumbDp - insetDp;

    final track = SizedBox(
      width: trackDpW,
      height: trackDpH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: PixelBox(
              style: trackStyle,
              logicalWidth: widget.trackLogicalWidth,
              logicalHeight: widget.trackLogicalHeight,
              width: trackDpW,
              height: trackDpH,
            ),
          ),
          AnimatedPositioned(
            duration: widget.animationDuration,
            curve: Curves.easeOut,
            left: widget.value ? onLeft : insetDp,
            top: insetDp,
            width: thumbDp,
            height: thumbDp,
            child: PixelBox(
              style: thumb!,
              logicalWidth: thumbSize,
              logicalHeight: thumbSize,
              width: thumbDp,
              height: thumbDp,
            ),
          ),
        ],
      ),
    );

    final tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _interactive ? _toggle : null,
      child: track,
    );

    final focusable = FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: _interactive && widget.autofocus,
      enabled: _interactive,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): _ToggleIntent(),
        SingleActivator(LogicalKeyboardKey.enter): _ToggleIntent(),
      },
      actions: {
        _ToggleIntent: CallbackAction<_ToggleIntent>(
          onInvoke: (_) {
            if (_interactive) _toggle();
            return null;
          },
        ),
      },
      child: tappable,
    );

    Widget visual = focusable;
    if (opacity < 1.0) {
      visual = Opacity(opacity: opacity, child: visual);
    }

    return Semantics(
      toggled: widget.value,
      enabled: _interactive,
      label: widget.semanticsLabel,
      excludeSemantics: widget.semanticsLabel != null,
      onTap: _interactive ? _toggle : null,
      child: visual,
    );
  }

  bool get _interactive => widget.enabled && widget.onChanged != null;

  void _toggle() {
    final cb = widget.onChanged;
    if (cb == null) return;
    cb(!widget.value);
  }
}

class _ToggleIntent extends Intent {
  const _ToggleIntent();
}
