// test/screenshots/scenes/pixel_slider_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const _track = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF222732),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);
const _fill = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
);
const _thumb = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);
const _disabledTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF222732),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

class PixelSliderScene extends StatelessWidget {
  const PixelSliderScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenshotFrame(
      title: 'PixelSlider',
      body: Center(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PixelSlider(
                value: 0.25,
                onChanged: (_) {},
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
              const SizedBox(height: 24),
              PixelSlider(
                value: 0.75,
                onChanged: (_) {},
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
              const SizedBox(height: 24),
              PixelSlider(
                value: 3,
                onChanged: (_) {},
                min: 1,
                max: 5,
                divisions: 4,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
              const SizedBox(height: 24),
              PixelSlider(
                value: 0.5,
                onChanged: null,
                enabled: false,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
                disabledStyle: _disabledTrack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
