@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _boundaryKey = Key('pixel-list-tile-golden-boundary');

const _panel = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFF333A4D),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

const _onPill = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
);

void main() {
  testWidgets('settings_row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1B1F2A),
          body: Center(
            child: SizedBox(
              width: 320,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: PixelListTile(
                  style: _panel,
                  title: const Text(
                    '효과음',
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
                  ),
                  subtitle: const Text(
                    '버튼 · 알림 픽셀 사운드',
                    style: TextStyle(color: Color(0xFFB7BCC9), fontSize: 11),
                  ),
                  trailing: SizedBox(
                    width: 36,
                    height: 18,
                    child: PixelBox(
                      style: _onPill,
                      logicalWidth: 18,
                      logicalHeight: 8,
                      width: 36,
                      height: 18,
                      child: const Center(
                        child: Text(
                          'ON',
                          style: TextStyle(
                              color: Color(0xFF2A4820), fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_list_tile/settings_row.png'),
    );
  });
}
