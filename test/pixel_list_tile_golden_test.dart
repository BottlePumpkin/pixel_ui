@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

// Goldens here lock in the *shape*: container corners, slot positions
// (leading / title-column / trailing), and the disabled visual fallback.
// We intentionally avoid Text widgets so the goldens are stable across
// platforms (CI Linux uses Ahem for unloaded fonts; macOS uses Mulmaru
// fallback). Text rendering is covered by the unit tests in
// pixel_list_tile_test.dart (e.g. find.text + position assertions).

const _boundaryKey = Key('pixel-list-tile-golden-boundary');

const _panel = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFF333A4D),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

const _disabled = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFF222732),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

const _onPill = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
);

const _ink = Color(0xFFFFFFFF);
const _muted = Color(0xFFB7BCC9);

/// A text-free placeholder that just draws a solid color block of a fixed
/// size. Used as `title` / `subtitle` / `leading` substitutes so the golden
/// only depends on layout + container shape, not glyph rendering.
class _Block extends StatelessWidget {
  const _Block({required this.width, required this.height, required this.color});
  final double width;
  final double height;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: width, height: height, color: color);
}

void main() {
  testWidgets('settings_row_three_states', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1B1F2A),
          body: Center(
            child: SizedBox(
              width: 320,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tile 1 — full slots: title + subtitle + trailing pill.
                    PixelListTile(
                      style: _panel,
                      title: const _Block(width: 70, height: 8, color: _ink),
                      subtitle: const _Block(width: 130, height: 5, color: _muted),
                      trailing: const PixelBox(
                        style: _onPill,
                        logicalWidth: 18,
                        logicalHeight: 8,
                        width: 36,
                        height: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tile 2 — title only.
                    PixelListTile(
                      style: _panel,
                      title: const _Block(width: 90, height: 8, color: _ink),
                    ),
                    const SizedBox(height: 6),
                    // Tile 3 — disabled, with explicit disabledStyle.
                    PixelListTile(
                      style: _panel,
                      disabledStyle: _disabled,
                      enabled: false,
                      title: const _Block(width: 70, height: 8, color: _ink),
                      subtitle: const _Block(width: 100, height: 5, color: _muted),
                    ),
                  ],
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
