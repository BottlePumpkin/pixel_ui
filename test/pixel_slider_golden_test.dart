@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _boundaryKey = Key('pixel-slider-golden-boundary');

const _track = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF222732),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);
const _fill = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
);
const _thumb = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);

Widget _frame({required Widget slider}) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF1B1F2A),
      body: Center(
        child: SizedBox(
          width: 320,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: slider,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _frameNarrow({required Widget slider}) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF1B1F2A),
      body: Center(
        child: SizedBox(
          width: 200,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: slider,
            ),
          ),
        ),
      ),
    ),
  );
}

PixelSlider _continuous(double v) => PixelSlider(
      value: v,
      onChanged: (_) {},
      trackStyle: _track,
      fillStyle: _fill,
      thumbStyle: _thumb,
    );

PixelSlider _discrete({required double v}) => PixelSlider(
      value: v,
      onChanged: (_) {},
      min: 1,
      max: 5,
      divisions: 4,
      trackStyle: _track,
      fillStyle: _fill,
      thumbStyle: _thumb,
    );

void main() {
  testWidgets('continuous value=0', (tester) async {
    await tester.pumpWidget(_frame(slider: _continuous(0)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/value_0.png'),
    );
  });

  testWidgets('continuous value=0.5', (tester) async {
    await tester.pumpWidget(_frame(slider: _continuous(0.5)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/value_half.png'),
    );
  });

  testWidgets('continuous value=1.0', (tester) async {
    await tester.pumpWidget(_frame(slider: _continuous(1.0)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/value_1.png'),
    );
  });

  testWidgets('discrete step 2 of 5', (tester) async {
    await tester.pumpWidget(_frame(slider: _discrete(v: 2)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/discrete_step_2_of_5.png'),
    );
  });

  testWidgets('discrete step 5 of 5', (tester) async {
    await tester.pumpWidget(_frame(slider: _discrete(v: 5)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/discrete_step_5_of_5.png'),
    );
  });

  testWidgets('narrow width=200, continuous value=0', (tester) async {
    await tester.pumpWidget(_frameNarrow(slider: _continuous(0)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/narrow_value_0.png'),
    );
  });

  testWidgets('narrow width=200, continuous value=0.5', (tester) async {
    await tester.pumpWidget(_frameNarrow(slider: _continuous(0.5)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/narrow_value_half.png'),
    );
  });

  testWidgets('narrow width=200, continuous value=1.0', (tester) async {
    await tester.pumpWidget(_frameNarrow(slider: _continuous(1.0)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_slider/narrow_value_1.png'),
    );
  });
}
