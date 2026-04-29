import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_section_header.dart';
import '../_shared/style_section.dart';
import 'switch_state.dart';

class SwitchControls extends StatelessWidget {
  final SwitchState state;
  const SwitchControls({super.key, required this.state});

  static const _disabledDefault = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF333333),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StyleSection(
              title: 'ON TRACK',
              value: state.onTrack,
              onChanged: state.setOnTrack,
            ),
            StyleSection(
              title: 'OFF TRACK',
              value: state.offTrack,
              onChanged: state.setOffTrack,
              collapsedByDefault: true,
            ),
            StyleSection(
              title: 'THUMB',
              value: state.thumb,
              onChanged: state.setThumb,
              collapsedByDefault: true,
            ),
            NullableStyleSection(
              title: 'DISABLED',
              value: state.disabledStyle,
              defaultWhenEnabling: _disabledDefault,
              onChanged: state.setDisabled,
            ),
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PixelSectionHeader('PREVIEW VALUE'),
                  Row(
                    children: [
                      const Text('OFF'),
                      const SizedBox(width: 12),
                      Switch(
                        value: state.previewValue,
                        onChanged: (_) => state.togglePreviewValue(),
                      ),
                      const SizedBox(width: 12),
                      const Text('ON'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
