// test/screenshots/scenes/corners_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const Color _fill = Color(0xFF5A8A3A);
const Color _border = Color(0xFF2A4820);
const Color _accentFill = Color(0xFFE07A3C);
const Color _accentBorder = Color(0xFF8B3E1A);
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
        const SizedBox(height: 12),
        Text(label, style: PixelText.mulmaru(fontSize: 18, color: _label)),
      ],
    );
  }
}

class CornersScene extends StatelessWidget {
  const CornersScene({super.key});

  @override
  Widget build(BuildContext context) {
    const presets = <(String, PixelCorners)>[
      ('sharp', PixelCorners.sharp),
      ('xs', PixelCorners.xs),
      ('sm', PixelCorners.sm),
      ('md', PixelCorners.md),
      ('lg', PixelCorners.lg),
      ('xl', PixelCorners.xl),
    ];

    return ScreenshotFrame(
      title: 'Corners',
      body: Center(
        child: Wrap(
          spacing: 40,
          runSpacing: 40,
          alignment: WrapAlignment.center,
          children: [
            for (final (label, corners) in presets)
              _Labelled(
                label,
                PixelBox(
                  logicalWidth: 16,
                  logicalHeight: 16,
                  width: 128,
                  style: PixelShapeStyle(
                    corners: corners,
                    fillColor: _fill,
                    borderColor: _border,
                    borderWidth: 1,
                  ),
                ),
              ),
            _Labelled(
              'only(top)',
              PixelBox(
                logicalWidth: 32,
                logicalHeight: 16,
                width: 256,
                style: const PixelShapeStyle(
                  corners: PixelCorners.only(tl: [3, 2, 1], tr: [3, 2, 1]),
                  fillColor: _accentFill,
                  borderColor: _accentBorder,
                  borderWidth: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
