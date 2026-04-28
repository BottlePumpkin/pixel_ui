import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widget_tuner.dart';
import '../_shared/code_view.dart';
import 'switch_code.dart';
import 'switch_controls.dart';
import 'switch_preview.dart';
import 'switch_state.dart';

class SwitchWidgetTuner implements WidgetTuner {
  final SwitchState _state = SwitchState();

  @override
  String get name => 'PixelSwitch';

  @override
  Widget get pixelIcon => const _SwitchIcon();

  @override
  Widget buildControls(BuildContext context) =>
      SwitchControls(state: _state);

  @override
  Widget buildPreview(BuildContext context) =>
      SwitchPreview(state: _state);

  @override
  Widget buildCode(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => CodeView(code: generateSwitchCode(_state)),
    );
  }

  @override
  void dispose() => _state.dispose();
}

class _SwitchIcon extends StatelessWidget {
  const _SwitchIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 12,
      child: Stack(
        children: [
          Positioned.fill(
            child: PixelBox(
              style: const PixelShapeStyle(
                corners: PixelCorners.sm,
                fillColor: Color(0xFFFFD643),
                borderColor: Color(0xFF2A4820),
                borderWidth: 1,
              ),
              logicalWidth: 16,
              logicalHeight: 8,
              width: 24,
              height: 12,
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            width: 10,
            height: 10,
            child: PixelBox(
              style: const PixelShapeStyle(
                corners: PixelCorners.sm,
                fillColor: Color(0xFFFFFFFF),
              ),
              logicalWidth: 8,
              logicalHeight: 8,
              width: 10,
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}
