import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_section_header.dart';
import '../_shared/checker_painter.dart';
import 'switch_state.dart';

class SwitchPreview extends StatelessWidget {
  final SwitchState state;
  const SwitchPreview({super.key, required this.state});

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
                child: AnimatedBuilder(
                  animation: state,
                  builder: (context, _) {
                    return PixelSwitch(
                      value: state.previewValue,
                      onChanged: (_) => state.togglePreviewValue(),
                      onTrackStyle: state.onTrack,
                      offTrackStyle: state.offTrack,
                      thumbStyle: state.thumb,
                      disabledStyle: state.disabledStyle,
                      trackLogicalWidth: 24,
                      trackLogicalHeight: 12,
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
