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

/// Umbrella extension grouping per-component pixel themes.
///
/// Used as a convenient entry point for [pixelUiTheme]; individual
/// [PixelBoxTheme] / [PixelButtonTheme] extensions remain the source of
/// truth resolved by widgets.
class PixelTheme extends ThemeExtension<PixelTheme> {
  final PixelBoxTheme? box;
  final PixelButtonTheme? button;

  const PixelTheme({this.box, this.button});

  @override
  PixelTheme copyWith({PixelBoxTheme? box, PixelButtonTheme? button}) {
    return PixelTheme(
      box: box ?? this.box,
      button: button ?? this.button,
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
}) {
  final data = base ?? ThemeData();
  final resolvedBox = boxTheme ?? pixelTheme?.box;
  final resolvedButton = buttonTheme ?? pixelTheme?.button;

  final preserved = Map<Object, ThemeExtension<dynamic>>.of(data.extensions)
    ..remove(PixelTheme)
    ..remove(PixelBoxTheme)
    ..remove(PixelButtonTheme);
  final merged = [
    ...preserved.values,
    ?pixelTheme,
    ?resolvedBox,
    ?resolvedButton,
  ];

  return data.copyWith(extensions: merged);
}

/// Convenience accessor: `context.pixelTheme<PixelBoxTheme>()`.
extension PixelThemeContext on BuildContext {
  T? pixelTheme<T extends ThemeExtension<T>>() => Theme.of(this).extension<T>();
}
