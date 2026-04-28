@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _boundaryKey = Key('pixel-switch-golden-boundary');

const _onTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
  borderColor: Color(0xFF2A4820),
  borderWidth: 1,
);
const _offTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF555E73),
  borderColor: Color(0xFF12141A),
  borderWidth: 1,
);
const _thumb = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFFFFF),
);

Widget _frame(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFF1B1F2A),
      body: Center(
        child: RepaintBoundary(
          key: _boundaryKey,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
      ),
    ),
  );
}

PixelSwitch _switch({required bool value}) => PixelSwitch(
      value: value,
      onChanged: (_) {},
      onTrackStyle: _onTrack,
      offTrackStyle: _offTrack,
      thumbStyle: _thumb,
    );

void main() {
  testWidgets('on', (tester) async {
    await tester.pumpWidget(_frame(_switch(value: true)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_switch/on.png'),
    );
  });

  testWidgets('off', (tester) async {
    await tester.pumpWidget(_frame(_switch(value: false)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_switch/off.png'),
    );
  });

  testWidgets('transition mid-frame', (tester) async {
    // Pump value=false, settle, then flip to true and only pump halfway.
    await tester.pumpWidget(_frame(_switch(value: false)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_frame(_switch(value: true)));
    // 60ms is exactly half of the default 120ms animation.
    await tester.pump(const Duration(milliseconds: 60));
    await expectLater(
      find.byKey(_boundaryKey),
      matchesGoldenFile('goldens/pixel_switch/transition.png'),
    );
  });
}
