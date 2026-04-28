import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widget_tuner.dart';
import '../_shared/code_view.dart';
import 'slider_code.dart';
import 'slider_controls.dart';
import 'slider_preview.dart';
import 'slider_state.dart';

class SliderWidgetTuner implements WidgetTuner {
  final SliderState _state = SliderState();

  @override
  String get name => 'PixelSlider';

  @override
  Widget get pixelIcon => const _SliderIcon();

  @override
  Widget buildControls(BuildContext context) =>
      SliderControls(state: _state);

  @override
  Widget buildPreview(BuildContext context) =>
      SliderPreview(state: _state);

  @override
  Widget buildCode(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => CodeView(code: generateSliderCode(_state)),
    );
  }

  @override
  void dispose() => _state.dispose();
}

class _SliderIcon extends StatelessWidget {
  const _SliderIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 12,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 5,
            height: 2,
            child: PixelBox(
              style: const PixelShapeStyle(
                corners: PixelCorners.sm,
                fillColor: Color(0xFF222732),
              ),
              logicalWidth: 16,
              logicalHeight: 2,
              width: 24,
              height: 2,
            ),
          ),
          Positioned(
            left: 10,
            top: 2,
            width: 4,
            height: 8,
            child: PixelBox(
              style: const PixelShapeStyle(
                corners: PixelCorners.sm,
                fillColor: Color(0xFFFFFFFF),
              ),
              logicalWidth: 4,
              logicalHeight: 8,
              width: 4,
              height: 8,
            ),
          ),
        ],
      ),
    );
  }
}
