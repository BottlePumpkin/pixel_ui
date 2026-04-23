import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Section title with a 4px vertical accent bar on the left.
class PixelSectionHeader extends StatelessWidget {
  final String title;
  const PixelSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          const SizedBox(
            width: 4,
            height: 20,
            child: ColoredBox(color: Color(0xFF5A8A3A)),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: PixelText.mulmaru(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
