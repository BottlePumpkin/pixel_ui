// test/screenshots/scenes/shadows_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const Color _fill = Color(0xFFFFD643);
const Color _border = Color(0xFF8A5A10);
const Color _shadow = Color(0xFF8A5A10);
const Color _label = Color(0xFF2A2A2A);

class _Labelled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labelled(this.label, this.child);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 16),
        Text(label, style: PixelText.mulmaru(fontSize: 20, color: _label)),
      ],
    );
  }
}

class ShadowsScene extends StatelessWidget {
  const ShadowsScene({super.key});

  @override
  Widget build(BuildContext context) {
    PixelShapeStyle styleWith(PixelShadow shadow) => PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: shadow,
        );

    return ScreenshotFrame(
      title: 'Shadows',
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Labelled(
              'sm (1,1)',
              PixelBox(
                logicalWidth: 16,
                logicalHeight: 16,
                width: 200,
                style: styleWith(PixelShadow.sm(_shadow)),
              ),
            ),
            _Labelled(
              'md (2,2)',
              PixelBox(
                logicalWidth: 16,
                logicalHeight: 16,
                width: 200,
                style: styleWith(PixelShadow.md(_shadow)),
              ),
            ),
            _Labelled(
              'lg (4,4)',
              PixelBox(
                logicalWidth: 16,
                logicalHeight: 16,
                width: 200,
                style: styleWith(PixelShadow.lg(_shadow)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
