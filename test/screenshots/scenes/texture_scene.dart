// test/screenshots/scenes/texture_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const Color _fill = Color(0xFFFFD643);
const Color _border = Color(0xFF8A5A10);
const Color _textureColor = Color(0xFFFFF7D0);
const Color _labelColor = Color(0xFF2A2A2A);

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
        Text(label, style: PixelText.mulmaru(fontSize: 20, color: _labelColor)),
      ],
    );
  }
}

class TextureScene extends StatelessWidget {
  const TextureScene({super.key});

  @override
  Widget build(BuildContext context) {
    const plainStyle = PixelShapeStyle(
      corners: PixelCorners.md,
      fillColor: _fill,
      borderColor: _border,
      borderWidth: 1,
    );
    const texturedStyle = PixelShapeStyle(
      corners: PixelCorners.md,
      fillColor: _fill,
      borderColor: _border,
      borderWidth: 1,
      texture: PixelTexture(
        color: _textureColor,
        density: 0.15,
        size: 1,
        seed: 7,
      ),
    );

    return ScreenshotFrame(
      title: 'Texture',
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _Labelled(
              'plain',
              PixelBox(
                logicalWidth: 20,
                logicalHeight: 20,
                width: 320,
                style: plainStyle,
              ),
            ),
            _Labelled(
              'textured',
              PixelBox(
                logicalWidth: 20,
                logicalHeight: 20,
                width: 320,
                style: texturedStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
