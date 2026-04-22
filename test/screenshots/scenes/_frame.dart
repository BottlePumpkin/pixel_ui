// test/screenshots/scenes/_frame.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

/// Shared 1280×720 cream-background frame used by every screenshot scene.
///
/// [title] is rendered at the top with `PixelText.mulmaru(fontSize: 32)`.
/// Pass `null` to omit — used by the hero scene, whose body already carries
/// a large logo.
class ScreenshotFrame extends StatelessWidget {
  static const double logicalWidth = 1280;
  static const double logicalHeight = 720;
  static const Color backgroundColor = Color(0xFFF5F1E8);
  static const Color titleColor = Color(0xFF2A2A2A);

  final String? title;
  final Widget body;

  const ScreenshotFrame({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: logicalWidth,
      height: logicalHeight,
      child: ColoredBox(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: PixelText.mulmaru(fontSize: 32, color: titleColor),
                ),
                const SizedBox(height: 32),
              ],
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
