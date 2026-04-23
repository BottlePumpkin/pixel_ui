import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Generates a Dart source snippet declaring a `const style = PixelShapeStyle(...)`
/// equivalent to the given [style]. Nullable fields are omitted when null.
String generateCode(PixelShapeStyle style) {
  final lines = <String>['const style = PixelShapeStyle('];

  lines.add('  corners: ${_corners(style.corners)},');
  lines.add('  fillColor: ${_color(style.fillColor)},');

  if (style.borderColor != null) {
    lines.add('  borderColor: ${_color(style.borderColor!)},');
    lines.add('  borderWidth: ${style.borderWidth},');
  }

  if (style.shadow != null) {
    final s = style.shadow!;
    lines.add('  shadow: PixelShadow(');
    lines.add(
      '    offset: Offset(${s.offset.dx.toInt()}, ${s.offset.dy.toInt()}),',
    );
    lines.add('    color: ${_color(s.color)},');
    lines.add('  ),');
  }

  if (style.texture != null) {
    final t = style.texture!;
    lines.add('  texture: PixelTexture(');
    lines.add('    density: ${t.density},');
    lines.add('    size: ${t.size},');
    lines.add('    seed: ${t.seed},');
    lines.add('    color: ${_color(t.color)},');
    lines.add('  ),');
  }

  lines.add(');');
  return lines.join('\n');
}

String _color(Color c) {
  final v = c.toARGB32();
  return 'Color(0x${v.toRadixString(16).toUpperCase().padLeft(8, '0')})';
}

String _corners(PixelCorners corners) {
  // Preset identity check first (object identity for the static const presets).
  if (identical(corners, PixelCorners.sharp)) return 'PixelCorners.sharp';
  if (identical(corners, PixelCorners.xs)) return 'PixelCorners.xs';
  if (identical(corners, PixelCorners.sm)) return 'PixelCorners.sm';
  if (identical(corners, PixelCorners.md)) return 'PixelCorners.md';
  if (identical(corners, PixelCorners.lg)) return 'PixelCorners.lg';
  if (identical(corners, PixelCorners.xl)) return 'PixelCorners.xl';

  // Preset equality check (fallback for re-constructed equivalents).
  if (corners == PixelCorners.sharp) return 'PixelCorners.sharp';
  if (corners == PixelCorners.xs) return 'PixelCorners.xs';
  if (corners == PixelCorners.sm) return 'PixelCorners.sm';
  if (corners == PixelCorners.md) return 'PixelCorners.md';
  if (corners == PixelCorners.lg) return 'PixelCorners.lg';
  if (corners == PixelCorners.xl) return 'PixelCorners.xl';

  // Custom symmetric corners — tuner only produces symmetric patterns via the
  // depth slider, so emit `PixelCorners.all(pattern)` using the tl pattern.
  final pattern = corners.tl;
  if (pattern.isEmpty) return 'PixelCorners.sharp';
  return 'PixelCorners.all([${pattern.join(', ')}])';
}
