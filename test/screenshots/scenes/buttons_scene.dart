// test/screenshots/scenes/buttons_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const PixelShapeStyle _normalStyle = PixelShapeStyle(
  corners: PixelCorners.lg,
  fillColor: Color(0xFF5A8A3A),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
  shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
);
const PixelShapeStyle _pressedStyle = PixelShapeStyle(
  corners: PixelCorners.lg,
  fillColor: Color(0xFF3E6028),
  borderColor: Color(0xFF1A3010),
  borderWidth: 1,
);
const Color _labelColor = Color(0xFF2A2A2A);

TextStyle _buttonTextStyle() => PixelText.mulmaru(
      fontSize: 22,
      color: const Color(0xFFFFFFFF),
      shadowColor: const Color(0xFF1A3010),
    );

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
        Text(label, style: PixelText.mulmaru(fontSize: 18, color: _labelColor)),
      ],
    );
  }
}

/// 04_buttons — normal / statically-rendered pressed / disabled.
class ButtonsScene extends StatelessWidget {
  const ButtonsScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenshotFrame(
      title: 'Buttons',
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Labelled(
              'normal',
              PixelButton(
                logicalWidth: 60,
                logicalHeight: 18,
                width: 280,
                normalStyle: _normalStyle,
                onPressed: () {},
                child: Text('TAP ME', style: _buttonTextStyle()),
              ),
            ),
            _Labelled(
              'pressed',
              PixelButton(
                logicalWidth: 60,
                logicalHeight: 18,
                width: 280,
                normalStyle: _pressedStyle,
                onPressed: () {},
                child: Text('PRESSED', style: _buttonTextStyle()),
              ),
            ),
            _Labelled(
              'disabled',
              PixelButton(
                logicalWidth: 60,
                logicalHeight: 18,
                width: 280,
                normalStyle: _normalStyle,
                onPressed: null,
                child: Text('DISABLED', style: _buttonTextStyle()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
