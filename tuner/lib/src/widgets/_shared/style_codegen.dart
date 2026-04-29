import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Formats a [Color] as `Color(0xAARRGGBB)` with uppercase 8-digit hex.
String emitColor(Color c) {
  final v = c.toARGB32();
  return 'Color(0x${v.toRadixString(16).toUpperCase().padLeft(8, '0')})';
}

/// Emits the most concise Dart literal representing [corners].
///
/// Resolution order:
/// 1. Identity match against `PixelCorners.<preset>` (object identity).
/// 2. Equality match against the same presets (handles reconstructed equivalents).
/// 3. Symmetric custom pattern → `PixelCorners.all([...])`.
String emitCorners(PixelCorners corners) {
  if (identical(corners, PixelCorners.sharp)) return 'PixelCorners.sharp';
  if (identical(corners, PixelCorners.xs)) return 'PixelCorners.xs';
  if (identical(corners, PixelCorners.sm)) return 'PixelCorners.sm';
  if (identical(corners, PixelCorners.md)) return 'PixelCorners.md';
  if (identical(corners, PixelCorners.lg)) return 'PixelCorners.lg';
  if (identical(corners, PixelCorners.xl)) return 'PixelCorners.xl';

  if (corners == PixelCorners.sharp) return 'PixelCorners.sharp';
  if (corners == PixelCorners.xs) return 'PixelCorners.xs';
  if (corners == PixelCorners.sm) return 'PixelCorners.sm';
  if (corners == PixelCorners.md) return 'PixelCorners.md';
  if (corners == PixelCorners.lg) return 'PixelCorners.lg';
  if (corners == PixelCorners.xl) return 'PixelCorners.xl';

  final pattern = corners.tl;
  if (pattern.isEmpty) return 'PixelCorners.sharp';
  return 'PixelCorners.all([${pattern.join(', ')}])';
}

/// Emits the lines for a `shadow: PixelShadow(...)` block (2-space indent).
/// Lines do NOT include a trailing newline; caller joins them.
List<String> emitShadowLines(PixelShadow s) {
  final lines = <String>[
    '  shadow: PixelShadow(',
    '    offset: Offset(${s.offset.dx.toInt()}, ${s.offset.dy.toInt()}),',
    '    color: ${emitColor(s.color)},',
  ];
  if (s.style != PixelShadowStyle.solid) {
    lines.add('    style: PixelShadowStyle.${s.style.name},');
  }
  lines.add('  ),');
  return lines;
}

/// Emits the lines for a `texture: PixelTexture(...)` block.
List<String> emitTextureLines(PixelTexture t) {
  return <String>[
    '  texture: PixelTexture(',
    '    density: ${t.density},',
    '    size: ${t.size},',
    '    seed: ${t.seed},',
    '    color: ${emitColor(t.color)},',
    '  ),',
  ];
}

/// Emits a complete `const $varName = PixelShapeStyle(...);` block.
/// Nullable fields (`borderColor`, `shadow`, `texture`) are omitted when null.
/// `borderWidth` is omitted whenever `borderColor` is null.
List<String> emitStyleConst(PixelShapeStyle s, String varName) {
  final lines = <String>['const $varName = PixelShapeStyle('];
  lines.add('  corners: ${emitCorners(s.corners)},');
  lines.add('  fillColor: ${emitColor(s.fillColor)},');
  if (s.borderColor != null) {
    lines.add('  borderColor: ${emitColor(s.borderColor!)},');
    lines.add('  borderWidth: ${s.borderWidth},');
  }
  if (s.shadow != null) lines.addAll(emitShadowLines(s.shadow!));
  if (s.texture != null) lines.addAll(emitTextureLines(s.texture!));
  lines.add(');');
  return lines;
}
