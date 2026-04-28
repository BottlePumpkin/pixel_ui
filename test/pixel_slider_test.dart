import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _track = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF222732),
);
const _fill = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFD643),
);
const _thumb = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFFFFFF),
);

void main() {
  testWidgets('renders track + fill + thumb (3 painters)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: PixelSlider(
                value: 0.5,
                onChanged: (_) {},
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
            ),
          ),
        ),
      ),
    );
    final painters = _painters(tester);
    expect(painters.length, greaterThanOrEqualTo(3));
    expect(painters.any((p) => p.style == _track), isTrue);
    expect(painters.any((p) => p.style == _fill), isTrue);
    expect(painters.any((p) => p.style == _thumb), isTrue);
  });

  testWidgets('thumb x position scales with value', (tester) async {
    Widget build(double v) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: PixelSlider(
                  value: v,
                  onChanged: (_) {},
                  trackStyle: _track,
                  fillStyle: _fill,
                  thumbStyle: _thumb,
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(build(0.0));
    await tester.pumpAndSettle();
    final atMin = _thumbCenter(tester);

    await tester.pumpWidget(build(1.0));
    await tester.pumpAndSettle();
    final atMax = _thumbCenter(tester);

    expect(atMax.dx, greaterThan(atMin.dx));
  });

  testWidgets('tap at center sets value to ~0.5', (tester) async {
    double? newValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: PixelSlider(
                value: 0.0,
                onChanged: (v) => newValue = v,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tapAt(tester.getCenter(find.byType(PixelSlider)));
    await tester.pumpAndSettle();
    expect(newValue, isNotNull);
    // The thumb size shifts the mapping slightly (iOS-style geometry).
    // Center tap should land within ~10% of 0.5.
    expect(newValue, closeTo(0.5, 0.1));
  });

  testWidgets('drag from left to right increases value', (tester) async {
    double current = 0.0;
    await tester.pumpWidget(
      StatefulBuilder(builder: (context, setState) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: PixelSlider(
                  value: current,
                  onChanged: (v) => setState(() => current = v),
                  trackStyle: _track,
                  fillStyle: _fill,
                  thumbStyle: _thumb,
                ),
              ),
            ),
          ),
        );
      }),
    );
    final start = tester.getTopLeft(find.byType(PixelSlider)) + const Offset(10, 8);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(150, 0));
    await tester.pumpAndSettle();
    await gesture.up();
    expect(current, greaterThan(0.5));
  });

  testWidgets('tap is a no-op when onChanged is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: PixelSlider(
                value: 0.5,
                onChanged: null,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tapAt(tester.getCenter(find.byType(PixelSlider)));
    await tester.pumpAndSettle();
    // No exception, no callback. Test passes if the pump doesn't throw.
    expect(true, isTrue);
  });
}

List<PixelShapePainter> _painters(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelSlider),
    matching: find.byType(CustomPaint),
  );
  return tester
      .widgetList<CustomPaint>(finder)
      .map((p) => p.painter)
      .whereType<PixelShapePainter>()
      .toList();
}

Offset _thumbCenter(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelSlider),
    matching: find.byType(CustomPaint),
  );
  for (final element in tester.elementList(finder)) {
    final paint = element.widget as CustomPaint;
    final painter = paint.painter;
    if (painter is PixelShapePainter && painter.style == _thumb) {
      return tester.getCenter(find.byElementPredicate((e) => e == element));
    }
  }
  throw StateError('Thumb CustomPaint not found');
}
