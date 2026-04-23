@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _fill = Color(0xFF00FF00);
const _border = Color(0xFF003300);
const _shadowColor = Color(0xFF222222);
const _textureColor = Color(0xFF003300);

const _boundaryKey = Key('golden-boundary');

Future<void> _pumpBox(WidgetTester tester, PixelShapeStyle style) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: _boundaryKey,
          child: PixelBox(
            logicalWidth: 16,
            logicalHeight: 16,
            style: style,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('PixelShapePainter goldens', () {
    testWidgets('corners md', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/corners_md.png'),
      );
    });

    testWidgets('corners sharp', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.sharp,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/corners_sharp.png'),
      );
    });

    testWidgets('corners xs', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.xs,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/corners_xs.png'),
      );
    });

    testWidgets('corners sm', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.sm,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/corners_sm.png'),
      );
    });

    testWidgets('corners lg', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.lg,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/corners_lg.png'),
      );
    });

    testWidgets('corners xl', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.xl,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/corners_xl.png'),
      );
    });

    testWidgets('shadow sm', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.sm(_shadowColor),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_sm.png'),
      );
    });

    testWidgets('shadow md', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.md(_shadowColor),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_md.png'),
      );
    });

    testWidgets('shadow lg', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.lg(_shadowColor),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_lg.png'),
      );
    });

    testWidgets('texture off', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/texture_off.png'),
      );
    });

    testWidgets('texture on', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          texture: PixelTexture(
            color: _textureColor,
            density: 0.15,
            size: 1,
            seed: 42,
          ),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/texture_on.png'),
      );
    });

    testWidgets('asymmetric tabs (top-left + bottom-right)', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.only(
            tl: [3, 2, 1],
            tr: [],
            bl: [],
            br: [3, 2, 1],
          ),
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/asymmetric_tabs.png'),
      );
    });
  });
}
