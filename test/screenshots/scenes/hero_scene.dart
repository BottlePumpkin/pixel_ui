// test/screenshots/scenes/hero_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const Color _logoFill = Color(0xFFE8DFC6);
const Color _logoBorder = Color(0xFF2A2A2A);
const Color _logoShadow = Color(0xFF2A2A2A);
const Color _logoTexture = Color(0xFFFFFFFF);
const Color _logoTextColor = Color(0xFF2A2A2A);
const Color _logoTextShadow = Color(0xFFE07A3C);
const Color _primaryFill = Color(0xFF5A8A3A);
const Color _primaryBorder = Color(0xFF2A4820);
const Color _primaryShadow = Color(0xFF1A3010);
const Color _accentFill = Color(0xFFFFD643);
const Color _accentBorder = Color(0xFF8A5A10);
const Color _accentTexture = Color(0xFFFFF7D0);

/// 01_hero — thumbnail for pub.dev card. Title label omitted because the
/// large "PIXEL UI" logo already serves that role.
class HeroScene extends StatelessWidget {
  const HeroScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenshotFrame(
      title: null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PixelBox(
            logicalWidth: 100,
            logicalHeight: 40,
            width: 900,
            style: const PixelShapeStyle(
              corners: PixelCorners.lg,
              fillColor: _logoFill,
              borderColor: _logoBorder,
              borderWidth: 1,
              shadow: PixelShadow(offset: Offset(2, 2), color: _logoShadow),
              texture: PixelTexture(
                color: _logoTexture,
                density: 0.08,
                size: 1,
                seed: 13,
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PIXEL UI',
                  style: PixelText.mulmaru(
                    fontSize: 56,
                    color: _logoTextColor,
                    shadowColor: _logoTextShadow,
                    shadowOffset: const Offset(3, 3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PRIMITIVES + FONT',
                  style: PixelText.mulmaru(
                    fontSize: 20,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 46),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelBox(
                logicalWidth: 16,
                logicalHeight: 16,
                width: 160,
                style: PixelShapeStyle(
                  corners: PixelCorners.lg,
                  fillColor: _primaryFill,
                  borderColor: _primaryBorder,
                  borderWidth: 1,
                  shadow: PixelShadow.sm(_primaryShadow),
                ),
              ),
              const SizedBox(width: 32),
              PixelBox(
                logicalWidth: 20,
                logicalHeight: 20,
                width: 200,
                style: const PixelShapeStyle(
                  corners: PixelCorners.md,
                  fillColor: _accentFill,
                  borderColor: _accentBorder,
                  borderWidth: 1,
                  texture: PixelTexture(
                    color: _accentTexture,
                    density: 0.15,
                    size: 1,
                    seed: 7,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              PixelBox(
                logicalWidth: 32,
                logicalHeight: 16,
                width: 320,
                style: const PixelShapeStyle(
                  corners: PixelCorners.only(tl: [3, 2, 1], tr: [3, 2, 1]),
                  fillColor: Color(0xFFE07A3C),
                  borderColor: Color(0xFF8B3E1A),
                  borderWidth: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
