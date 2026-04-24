import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Asymmetric 4-corner stair pattern.
///
/// `[0]` is the outermost row; last element is closest to the center.
/// Empty list means that corner is square.
///
/// ```dart
/// // All four corners rounded with the same pattern
/// const PixelCorners.all([3, 2, 1])
///
/// // Only top corners rounded (tab shape)
/// const PixelCorners.only(tl: [3, 2, 1], tr: [3, 2, 1])
/// ```
@immutable
class PixelCorners {
  final List<int> tl;
  final List<int> tr;
  final List<int> bl;
  final List<int> br;

  const PixelCorners({
    required this.tl,
    required this.tr,
    required this.bl,
    required this.br,
  });

  /// All four corners share the same stair pattern.
  const PixelCorners.all(List<int> pattern)
      : tl = pattern,
        tr = pattern,
        bl = pattern,
        br = pattern;

  /// Specify only the corners you want rounded; others remain square.
  const PixelCorners.only({
    this.tl = const [],
    this.tr = const [],
    this.bl = const [],
    this.br = const [],
  });

  /// No rounded corners.
  static const sharp = PixelCorners.all([]);

  /// 1-pixel rounding.
  static const xs = PixelCorners.all([1]);

  /// Small: 2-row stair.
  static const sm = PixelCorners.all([2, 1]);

  /// Medium: 3-row stair.
  static const md = PixelCorners.all([3, 2, 1]);

  /// Large: 4-row stair with flattened inner row.
  static const lg = PixelCorners.all([4, 2, 1, 1]);

  /// Extra large: 6-row smooth stair.
  static const xl = PixelCorners.all([6, 5, 4, 3, 2, 1]);

  int get topInsetRows => tl.length > tr.length ? tl.length : tr.length;

  int get bottomInsetRows => bl.length > br.length ? bl.length : br.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelCorners &&
          listEquals(tl, other.tl) &&
          listEquals(tr, other.tr) &&
          listEquals(bl, other.bl) &&
          listEquals(br, other.br);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(tl),
        Object.hashAll(tr),
        Object.hashAll(bl),
        Object.hashAll(br),
      );
}

/// Rectangular region of the pixel shape to leave unpainted, in logical-pixel
/// units. Used by `PixelBox.label` to carve space out of the top border for
/// an overlaid label widget.
@immutable
class PixelBoxCutout {
  /// Leftmost logical column (inclusive) to start skipping from.
  final int left;

  /// Number of logical columns to skip.
  final int width;

  /// Number of logical rows — counted from the top edge (y = 0) — to skip.
  ///
  /// Defaults to 1 row, which covers the top border line. Raise this to also
  /// skip the first fill row when a thick border or tall label needs more
  /// breathing room.
  final int height;

  const PixelBoxCutout({
    required this.left,
    required this.width,
    this.height = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelBoxCutout &&
          left == other.left &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(left, width, height);
}

/// Rendering style of a [PixelShadow].
///
/// - [solid]: the shadow is a filled copy of the shape (default).
/// - [stipple]: the shadow is a 1-pixel checker pattern over the shape —
///   a softer, retro "dithered" aesthetic.
enum PixelShadowStyle { solid, stipple }

/// Pixel drop shadow. Offset is in logical pixel units.
@immutable
class PixelShadow {
  final Offset offset;
  final Color color;
  final PixelShadowStyle style;

  const PixelShadow({
    required this.offset,
    required this.color,
    this.style = PixelShadowStyle.solid,
  });

  /// Small shadow: offset (1, 1).
  factory PixelShadow.sm(
    Color color, {
    PixelShadowStyle style = PixelShadowStyle.solid,
  }) =>
      PixelShadow(offset: const Offset(1, 1), color: color, style: style);

  /// Medium shadow: offset (2, 2).
  factory PixelShadow.md(
    Color color, {
    PixelShadowStyle style = PixelShadowStyle.solid,
  }) =>
      PixelShadow(offset: const Offset(2, 2), color: color, style: style);

  /// Large shadow: offset (4, 4).
  factory PixelShadow.lg(
    Color color, {
    PixelShadowStyle style = PixelShadowStyle.solid,
  }) =>
      PixelShadow(offset: const Offset(4, 4), color: color, style: style);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelShadow &&
          offset == other.offset &&
          color == other.color &&
          style == other.style;

  @override
  int get hashCode => Object.hash(offset, color, style);
}

/// Deterministic noise texture overlay.
///
/// Uses an LCG (linear congruential generator) seeded with [seed], so the same
/// settings always produce the same pattern across platforms and builds.
@immutable
class PixelTexture {
  final Color color;

  /// Probability (0.0~1.0) that any given cell is painted.
  final double density;

  /// Cell size in logical pixel units.
  final int size;
  final int seed;

  const PixelTexture({
    required this.color,
    this.density = 0.15,
    this.size = 1,
    this.seed = 42,
  })  : assert(density >= 0 && density <= 1,
            'density must be in [0, 1] (got $density)'),
        assert(size >= 1, 'size must be >= 1 (got $size)');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelTexture &&
          color == other.color &&
          density == other.density &&
          size == other.size &&
          seed == other.seed;

  @override
  int get hashCode => Object.hash(color, density, size, seed);
}

/// Complete pixel shape style. Single value object for all visual properties.
///
/// Nullable fields ([borderColor], [shadow], [texture]) support the sentinel
/// [copyWith] pattern — pass `null` explicitly to clear, omit to preserve.
@immutable
class PixelShapeStyle {
  final PixelCorners corners;
  final Color fillColor;
  final Color? borderColor;
  final int borderWidth;
  final PixelShadow? shadow;
  final PixelTexture? texture;

  const PixelShapeStyle({
    required this.corners,
    required this.fillColor,
    this.borderColor,
    this.borderWidth = 0,
    this.shadow,
    this.texture,
  }) : assert(borderWidth >= 0,
            'borderWidth must be non-negative (got $borderWidth)');

  static const Object _unset = Object();

  /// Returns a copy with individual fields replaced.
  ///
  /// For nullable fields ([borderColor], [shadow], [texture]):
  ///   - Omit the parameter to preserve the current value.
  ///   - Pass `null` explicitly to clear the value.
  ///   - Pass a new value to replace.
  PixelShapeStyle copyWith({
    PixelCorners? corners,
    Color? fillColor,
    Object? borderColor = _unset,
    int? borderWidth,
    Object? shadow = _unset,
    Object? texture = _unset,
  }) {
    return PixelShapeStyle(
      corners: corners ?? this.corners,
      fillColor: fillColor ?? this.fillColor,
      borderColor: identical(borderColor, _unset)
          ? this.borderColor
          : borderColor as Color?,
      borderWidth: borderWidth ?? this.borderWidth,
      shadow: identical(shadow, _unset)
          ? this.shadow
          : shadow as PixelShadow?,
      texture: identical(texture, _unset)
          ? this.texture
          : texture as PixelTexture?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixelShapeStyle &&
          corners == other.corners &&
          fillColor == other.fillColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          shadow == other.shadow &&
          texture == other.texture;

  @override
  int get hashCode => Object.hash(
        corners,
        fillColor,
        borderColor,
        borderWidth,
        shadow,
        texture,
      );
}
