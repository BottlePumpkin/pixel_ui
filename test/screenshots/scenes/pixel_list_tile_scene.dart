// test/screenshots/scenes/pixel_list_tile_scene.dart
import 'package:flutter/widgets.dart';

import 'package:pixel_ui/pixel_ui.dart';

import '_frame.dart';

const _panel = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFF333A4D),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

const _pressedPanel = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFF464E66),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

const _ink = Color(0xFFFFFFFF);
const _muted = Color(0xFFB7BCC9);
const _accent = Color(0xFFFFD643);

class PixelListTileScene extends StatelessWidget {
  const PixelListTileScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenshotFrame(
      title: 'PixelListTile',
      body: Center(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PixelListTile(
                style: _panel,
                pressedStyle: _pressedPanel,
                title: Text('효과음',
                    style:
                        PixelText.mulmaru(fontSize: 14, color: _ink)),
                subtitle: Text('버튼 · 알림 픽셀 사운드',
                    style: PixelText.mulmaru(
                        fontSize: 11, color: _muted)),
                trailing: Text('ON',
                    style: PixelText.mulmaruMono(
                        fontSize: 12, color: _accent)),
                onTap: () {},
              ),
              const SizedBox(height: 6),
              PixelListTile(
                style: _panel,
                pressedStyle: _pressedPanel,
                title: Text('알림 설정',
                    style:
                        PixelText.mulmaru(fontSize: 14, color: _ink)),
                trailing: Text('›',
                    style: PixelText.mulmaru(
                        fontSize: 20, color: _muted)),
                onTap: () {},
              ),
              const SizedBox(height: 6),
              PixelListTile(
                style: _panel,
                disabledStyle: PixelShapeStyle(
                  corners: PixelCorners.md,
                  fillColor: const Color(0xFF222732),
                  borderColor: const Color(0xFF12141A),
                  borderWidth: 1,
                ),
                enabled: false,
                title: Text('베타 기능',
                    style:
                        PixelText.mulmaru(fontSize: 14, color: _ink)),
                subtitle: Text('곧 출시 예정',
                    style: PixelText.mulmaru(
                        fontSize: 11, color: _muted)),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
