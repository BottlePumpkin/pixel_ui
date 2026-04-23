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

    testWidgets('shadow negative offset', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow(
            offset: Offset(-2, -2),
            color: _shadowColor,
          ),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_negative.png'),
      );
    });

    testWidgets('shadow asymmetric offset', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow(
            offset: Offset(3, -1),
            color: _shadowColor,
          ),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_asymmetric.png'),
      );
    });

    testWidgets('shadow on sharp corners', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.sharp,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.md(_shadowColor),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_sharp.png'),
      );
    });

    testWidgets('shadow plus texture', (tester) async {
      await _pumpBox(
        tester,
        PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          shadow: PixelShadow.md(_shadowColor),
          texture: const PixelTexture(
            color: _textureColor,
            density: 0.15,
            size: 1,
            seed: 42,
          ),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/shadow_plus_texture.png'),
      );
    });

    testWidgets('texture dense', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          texture: PixelTexture(
            color: _textureColor,
            density: 0.5,
            size: 1,
            seed: 42,
          ),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/texture_dense.png'),
      );
    });

    testWidgets('texture size 2', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
          texture: PixelTexture(
            color: _textureColor,
            density: 0.25,
            size: 2,
            seed: 42,
          ),
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/texture_size2.png'),
      );
    });

    testWidgets('borderless fill only', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/borderless.png'),
      );
    });

    testWidgets('thick border (2px)', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.md,
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 2,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/border_thick.png'),
      );
    });

    testWidgets('asymmetric top tab only', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.only(
            tl: [3, 2, 1],
            tr: [3, 2, 1],
          ),
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/asymmetric_top_tab.png'),
      );
    });

    testWidgets('asymmetric bottom tab only', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.only(
            bl: [3, 2, 1],
            br: [3, 2, 1],
          ),
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/asymmetric_bottom_tab.png'),
      );
    });

    testWidgets('asymmetric single corner (tl only)', (tester) async {
      await _pumpBox(
        tester,
        const PixelShapeStyle(
          corners: PixelCorners.only(tl: [3, 2, 1]),
          fillColor: _fill,
          borderColor: _border,
          borderWidth: 1,
        ),
      );
      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('goldens/painter/asymmetric_tl_only.png'),
      );
    });
  });
}
