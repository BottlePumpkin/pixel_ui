import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _onTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
);
const _offTrack = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF555E73),
);
const _thumb = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFFFFF),
);

void main() {
  testWidgets('renders onTrackStyle when value is true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: true,
              onChanged: (_) {},
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
        ),
      ),
    );
    final painters = _painters(tester);
    expect(painters.first.style, _onTrack);
  });

  testWidgets('renders offTrackStyle when value is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: false,
              onChanged: (_) {},
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
        ),
      ),
    );
    final painters = _painters(tester);
    expect(painters.first.style, _offTrack);
  });
}

/// Returns the PixelShapePainter instances inside the PixelSwitch subtree
/// in render order (track first, then thumb once added).
List<PixelShapePainter> _painters(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelSwitch),
    matching: find.byType(CustomPaint),
  );
  return tester
      .widgetList<CustomPaint>(finder)
      .map((p) => p.painter)
      .whereType<PixelShapePainter>()
      .toList();
}
