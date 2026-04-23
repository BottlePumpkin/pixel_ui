import 'package:flutter/widgets.dart';

/// Namespace for bundled-font text styling helpers.
///
/// This is **not** a widget — it is a static container that exposes:
/// - [mulmaruFontFamily] and [mulmaruPackage] constants for manual TextStyle
///   construction.
/// - [mulmaru] factory returning a ready-made [TextStyle].
abstract class PixelText {
  PixelText._();

  /// Font family name of the bundled Mulmaru font.
  static const String mulmaruFontFamily = 'Mulmaru';

  /// Package name for font resolution. Pass to `TextStyle(package:)` when
  /// building custom styles.
  static const String mulmaruPackage = 'pixel_ui';

  /// Returns a [TextStyle] configured for the bundled Mulmaru pixel font.
  ///
  /// Defaults are tuned for pixel-perfect rendering:
  /// * [height] defaults to 1.0 (tight line height for pixel fonts).
  /// * [color] defaults to opaque black.
  ///
  /// Shadow resolution:
  /// * If [shadows] is provided, it is used verbatim and
  ///   [shadowColor]/[shadowOffset] are ignored.
  /// * Otherwise, if [shadowColor] is non-null, a single shadow with
  ///   [shadowOffset] is added.
  /// * Otherwise, no shadow is set.
  static TextStyle mulmaru({
    double fontSize = 16,
    Color color = const Color(0xFF000000),
    Color? shadowColor,
    Offset shadowOffset = const Offset(1, 1),
    double height = 1.0,
    FontWeight? fontWeight,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    final resolvedShadows = shadows ??
        (shadowColor != null
            ? <Shadow>[Shadow(offset: shadowOffset, color: shadowColor)]
            : null);

    return TextStyle(
      fontFamily: mulmaruFontFamily,
      package: mulmaruPackage,
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: resolvedShadows,
    );
  }

  /// Font family name of the bundled Mulmaru Mono (monospaced) font.
  static const String mulmaruMonoFontFamily = 'MulmaruMono';

  /// Returns a [TextStyle] configured for the bundled Mulmaru Mono pixel font.
  ///
  /// Identical semantics to [mulmaru] — see that method for shadow resolution
  /// rules and default justification.
  static TextStyle mulmaruMono({
    double fontSize = 16,
    Color color = const Color(0xFF000000),
    Color? shadowColor,
    Offset shadowOffset = const Offset(1, 1),
    double height = 1.0,
    FontWeight? fontWeight,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    final resolvedShadows = shadows ??
        (shadowColor != null
            ? <Shadow>[Shadow(offset: shadowOffset, color: shadowColor)]
            : null);

    return TextStyle(
      fontFamily: mulmaruMonoFontFamily,
      package: mulmaruPackage,
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: resolvedShadows,
    );
  }
}
