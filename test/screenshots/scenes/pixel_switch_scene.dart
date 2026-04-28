// test/screenshots/scenes/pixel_switch_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const _onTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
);
const _offTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF555E73),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);
const _thumb = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFFFFF),
);
const _disabledTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF222732),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

class PixelSwitchScene extends StatelessWidget {
  const PixelSwitchScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenshotFrame(
      title: 'PixelSwitch',
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PixelSwitch(
              value: true,
              onChanged: (_) {},
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
            const SizedBox(width: 32),
            PixelSwitch(
              value: false,
              onChanged: (_) {},
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
            const SizedBox(width: 32),
            PixelSwitch(
              value: true,
              onChanged: null,
              enabled: false,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
              disabledStyle: _disabledTrack,
            ),
          ],
        ),
      ),
    );
  }
}
