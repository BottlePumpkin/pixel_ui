@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _fill = Color(0xFF00FF00);
const _border = Color(0xFF003300);

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
  });
}
