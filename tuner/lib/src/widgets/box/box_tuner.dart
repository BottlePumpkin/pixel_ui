import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widget_tuner.dart';
import '../_shared/code_view.dart';
import 'box_code.dart';
import 'box_controls.dart';
import 'box_preview.dart';
import 'box_state.dart';

class BoxWidgetTuner implements WidgetTuner {
  final BoxState _state = BoxState();

  @override
  String get name => 'PixelBox';

  @override
  Widget get pixelIcon => const _BoxIcon();

  @override
  Widget buildControls(BuildContext context) => BoxControls(state: _state);

  @override
  Widget buildPreview(BuildContext context) => BoxPreview(state: _state);

  @override
  Widget buildCode(BuildContext context) {
    return ValueListenableBuilder<PixelShapeStyle>(
      valueListenable: _state,
      builder: (context, style, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _state.labelText,
          builder: (context, label, _) {
            return CodeView(code: generateBoxCode(style, labelText: label));
          },
        );
      },
    );
  }

  @override
  void dispose() => _state.dispose();
}

class _BoxIcon extends StatelessWidget {
  const _BoxIcon();

  static const _style = PixelShapeStyle(
    corners: PixelCorners.md,
    fillColor: Color(0xFF5A8A3A),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
  );

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      style: _style,
      logicalWidth: 16,
      logicalHeight: 16,
      width: 24,
      height: 24,
    );
  }
}
