import 'package:flutter/material.dart';

import 'package:pixel_ui/src/pixel_style.dart';

/// Signature for a user-supplied builder that produces a [CustomPainter]
/// from a [PixelShapeStyle] and logical dimensions.
///
/// Since 0.3.0 the builder also receives an optional [PixelBoxCutout]
/// describing any carve-out the enclosing `PixelBox` wants honored (used by
/// `PixelBox.label`). Custom builders may forward it to
/// [PixelShapePainter] or ignore it.
typedef PixelShapePainterBuilder = CustomPainter Function({
  required int logicalWidth,
  required int logicalHeight,
  required PixelShapeStyle style,
  PixelBoxCutout? labelCutout,
});

/// Theme overrides for [PixelBox].
///
/// `style` provides the default [PixelShapeStyle] for any [PixelBox] that
/// omits its own `style` prop. `painter` is an inert slot in 0.3.0 and will
/// be activated in #9.
class PixelBoxTheme extends ThemeExtension<PixelBoxTheme> {
  final PixelShapeStyle? style;
  final PixelShapePainterBuilder? painter;

  const PixelBoxTheme({this.style, this.painter});

  @override
  PixelBoxTheme copyWith({
    PixelShapeStyle? style,
    PixelShapePainterBuilder? painter,
  }) {
    return PixelBoxTheme(
      style: style ?? this.style,
      painter: painter ?? this.painter,
    );
  }

  @override
  PixelBoxTheme lerp(covariant ThemeExtension<PixelBoxTheme>? other, double t) {
    if (other is! PixelBoxTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Theme overrides for [PixelButton].
class PixelButtonTheme extends ThemeExtension<PixelButtonTheme> {
  final PixelShapeStyle? normalStyle;
  final PixelShapeStyle? pressedStyle;
  final PixelShapeStyle? disabledStyle;

  const PixelButtonTheme({
    this.normalStyle,
    this.pressedStyle,
    this.disabledStyle,
  });

  @override
  PixelButtonTheme copyWith({
    PixelShapeStyle? normalStyle,
    PixelShapeStyle? pressedStyle,
    PixelShapeStyle? disabledStyle,
  }) {
    return PixelButtonTheme(
      normalStyle: normalStyle ?? this.normalStyle,
      pressedStyle: pressedStyle ?? this.pressedStyle,
      disabledStyle: disabledStyle ?? this.disabledStyle,
    );
  }

  @override
  PixelButtonTheme lerp(
    covariant ThemeExtension<PixelButtonTheme>? other,
    double t,
  ) {
    if (other is! PixelButtonTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Theme overrides for [PixelListTile].
///
/// `style` provides the default container [PixelShapeStyle].
/// `pressedStyle` and `disabledStyle` are consulted when the tile is pressed
/// or `enabled == false`. `contentPadding` and `slotGap` set default inner
/// metrics; widget props override per call site.
class PixelListTileTheme extends ThemeExtension<PixelListTileTheme> {
  final PixelShapeStyle? style;
  final PixelShapeStyle? pressedStyle;
  final PixelShapeStyle? disabledStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double? slotGap;

  const PixelListTileTheme({
    this.style,
    this.pressedStyle,
    this.disabledStyle,
    this.contentPadding,
    this.slotGap,
  });

  @override
  PixelListTileTheme copyWith({
    PixelShapeStyle? style,
    PixelShapeStyle? pressedStyle,
    PixelShapeStyle? disabledStyle,
    EdgeInsetsGeometry? contentPadding,
    double? slotGap,
  }) {
    return PixelListTileTheme(
      style: style ?? this.style,
      pressedStyle: pressedStyle ?? this.pressedStyle,
      disabledStyle: disabledStyle ?? this.disabledStyle,
      contentPadding: contentPadding ?? this.contentPadding,
      slotGap: slotGap ?? this.slotGap,
    );
  }

  @override
  PixelListTileTheme lerp(
    covariant ThemeExtension<PixelListTileTheme>? other,
    double t,
  ) {
    if (other is! PixelListTileTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Theme overrides for [PixelSwitch].
///
/// `onTrackStyle` and `offTrackStyle` paint the track based on the switch's
/// `value`. `thumbStyle` paints the sliding thumb (independent of value).
/// `disabledStyle` is consulted when the switch's `enabled == false`; if
/// omitted, the widget falls back to painting the active track at 50%
/// opacity.
class PixelSwitchTheme extends ThemeExtension<PixelSwitchTheme> {
  final PixelShapeStyle? onTrackStyle;
  final PixelShapeStyle? offTrackStyle;
  final PixelShapeStyle? thumbStyle;
  final PixelShapeStyle? disabledStyle;

  const PixelSwitchTheme({
    this.onTrackStyle,
    this.offTrackStyle,
    this.thumbStyle,
    this.disabledStyle,
  });

  @override
  PixelSwitchTheme copyWith({
    PixelShapeStyle? onTrackStyle,
    PixelShapeStyle? offTrackStyle,
    PixelShapeStyle? thumbStyle,
    PixelShapeStyle? disabledStyle,
  }) {
    return PixelSwitchTheme(
      onTrackStyle: onTrackStyle ?? this.onTrackStyle,
      offTrackStyle: offTrackStyle ?? this.offTrackStyle,
      thumbStyle: thumbStyle ?? this.thumbStyle,
      disabledStyle: disabledStyle ?? this.disabledStyle,
    );
  }

  @override
  PixelSwitchTheme lerp(
    covariant ThemeExtension<PixelSwitchTheme>? other,
    double t,
  ) {
    if (other is! PixelSwitchTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Umbrella extension grouping per-component pixel themes.
///
/// Used as a convenient entry point for [pixelUiTheme]; individual
/// [PixelBoxTheme] / [PixelButtonTheme] extensions remain the source of
/// truth resolved by widgets.
class PixelTheme extends ThemeExtension<PixelTheme> {
  final PixelBoxTheme? box;
  final PixelButtonTheme? button;
  final PixelListTileTheme? listTile;

  const PixelTheme({this.box, this.button, this.listTile});

  @override
  PixelTheme copyWith({
    PixelBoxTheme? box,
    PixelButtonTheme? button,
    PixelListTileTheme? listTile,
  }) {
    return PixelTheme(
      box: box ?? this.box,
      button: button ?? this.button,
      listTile: listTile ?? this.listTile,
    );
  }

  @override
  PixelTheme lerp(covariant ThemeExtension<PixelTheme>? other, double t) {
    if (other is! PixelTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Builds a [ThemeData] with pixel_ui extensions registered.
///
/// Explicit [boxTheme] / [buttonTheme] take precedence over the matching
/// slots of [pixelTheme]. Unrelated extensions on [base] are preserved.
ThemeData pixelUiTheme({
  ThemeData? base,
  PixelTheme? pixelTheme,
  PixelBoxTheme? boxTheme,
  PixelButtonTheme? buttonTheme,
  PixelListTileTheme? listTileTheme,
}) {
  final data = base ?? ThemeData();
  final resolvedBox = boxTheme ?? pixelTheme?.box;
  final resolvedButton = buttonTheme ?? pixelTheme?.button;
  final resolvedListTile = listTileTheme ?? pixelTheme?.listTile;

  final preserved = Map<Object, ThemeExtension<dynamic>>.of(data.extensions)
    ..remove(PixelTheme)
    ..remove(PixelBoxTheme)
    ..remove(PixelButtonTheme)
    ..remove(PixelListTileTheme);
  final merged = [
    ...preserved.values,
    ?pixelTheme,
    ?resolvedBox,
    ?resolvedButton,
    ?resolvedListTile,
  ];

  return data.copyWith(extensions: merged);
}

/// Convenience accessor: `context.pixelTheme<PixelBoxTheme>()`.
extension PixelThemeContext on BuildContext {
  T? pixelTheme<T extends ThemeExtension<T>>() => Theme.of(this).extension<T>();
}
