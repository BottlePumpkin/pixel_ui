import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Single source of truth for the tuner's current [PixelShapeStyle].
///
/// The optional [labelText] is tracked separately because it is not a field of
/// [PixelShapeStyle] — it is a widget-level option on `PixelBox.label`.
class TunerState extends ValueNotifier<PixelShapeStyle> {
  TunerState() : super(_initial);

  static const _initial = PixelShapeStyle(
    corners: PixelCorners.lg,
    fillColor: Color(0xFF5A8A3A),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
    shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
  );

  final ValueNotifier<String?> labelText = ValueNotifier<String?>(null);

  void setCorners(PixelCorners corners) =>
      value = value.copyWith(corners: corners);

  void setFillColor(Color color) =>
      value = value.copyWith(fillColor: color);

  void setBorderColor(Color? color) =>
      value = value.copyWith(borderColor: color);

  void setBorderWidth(int width) =>
      value = value.copyWith(borderWidth: width);

  void setShadow(PixelShadow? shadow) =>
      value = value.copyWith(shadow: shadow);

  void setTexture(PixelTexture? texture) =>
      value = value.copyWith(texture: texture);

  void setLabel(String? text) {
    final trimmed = text == null || text.isEmpty ? null : text;
    labelText.value = trimmed;
  }

  @override
  void dispose() {
    labelText.dispose();
    super.dispose();
  }
}
