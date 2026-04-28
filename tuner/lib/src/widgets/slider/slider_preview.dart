import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_section_header.dart';
import '../_shared/checker_painter.dart';
import 'slider_state.dart';

class SliderPreview extends StatelessWidget {
  final SliderState state;
  const SliderPreview({super.key, required this.state});

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: AnimatedBuilder(
                    animation: state,
                    builder: (context, _) {
                      return PixelSlider(
                        value: state.previewValue,
                        onChanged: state.setPreviewValue,
                        min: state.min,
                        max: state.max,
                        divisions: state.divisions,
                        trackStyle: state.track,
                        fillStyle: state.fill,
                        thumbStyle: state.thumb,
                        disabledStyle: state.disabledStyle,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
