import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_section_header.dart';
import '../_shared/checker_painter.dart';
import 'box_state.dart';

/// Live PixelBox preview at logical 80×24, scale 6×, on a checkerboard
/// backdrop. Honors [state.labelText] when non-null.
class BoxPreview extends StatelessWidget {
  final BoxState state;
  const BoxPreview({super.key, required this.state});

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
              painter: CheckerPainter(),
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
