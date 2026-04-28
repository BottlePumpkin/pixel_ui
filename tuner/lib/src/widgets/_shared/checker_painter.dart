import 'package:flutter/widgets.dart';

/// Light/dark 8dp checker tile background, used as the preview backdrop
/// for all WidgetTuner preview panels.
class CheckerPainter extends CustomPainter {
  static const _tile = 8.0;
  static const _dark = Color(0xFFE0D9C4);
  static const _light = Color(0xFFEDE6D0);

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = _dark;
    final paintLight = Paint()..color = _light;
    canvas.drawRect(Offset.zero & size, paintLight);
    for (double y = 0; y < size.height; y += _tile) {
      for (double x = 0; x < size.width; x += _tile) {
        final isDark = ((x / _tile).floor() + (y / _tile).floor()) % 2 == 0;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, _tile, _tile), paintDark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CheckerPainter oldDelegate) => false;
}
