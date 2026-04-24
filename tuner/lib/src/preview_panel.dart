import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'tuner_state.dart';
import 'widgets/pixel_card.dart';
import 'widgets/pixel_section_header.dart';

/// Dominant preview area: checker-textured backdrop with the current style
/// rendered as a PixelBox at 6x logical-to-render scale.
class PreviewPanel extends StatelessWidget {
  final TunerState state;
  const PreviewPanel({super.key, required this.state});

  static const _logicalWidth = 80;
  static const _logicalHeight = 24;
  static const _scale = 6;

  @override
  Widget build(BuildContext context) {
    return PixelCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PixelSectionHeader('PREVIEW'),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 2,
            child: CustomPaint(
              painter: _CheckerPainter(),
              child: Center(
                child: ValueListenableBuilder<PixelShapeStyle>(
                  valueListenable: state,
                  builder: (context, style, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: state.labelText,
                      builder: (context, labelText, _) {
                        return PixelBox(
                          logicalWidth: _logicalWidth,
                          logicalHeight: _logicalHeight,
                          width: _logicalWidth * _scale.toDouble(),
                          height: _logicalHeight * _scale.toDouble(),
                          style: style,
                          label: labelText == null
                              ? null
                              : Text(
                                  labelText,
                                  style: PixelText.mulmaru(
                                    fontSize: 12,
                                    color: style.borderColor ?? style.fillColor,
                                  ),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
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
  bool shouldRepaint(_CheckerPainter oldDelegate) => false;
}
