import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _style = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFFFF0000),
  borderColor: Color(0xFF550000),
  borderWidth: 1,
);

PixelShapePainter _painter(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelBox),
    matching: find.byType(CustomPaint),
  );
  return tester
      .widgetList<CustomPaint>(finder)
      .map((p) => p.painter)
      .whereType<PixelShapePainter>()
      .first;
}

void main() {
  testWidgets('omitting label → no labelCutout on painter', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 32,
            logicalHeight: 16,
            style: _style,
          ),
        ),
      ),
    );
    expect(_painter(tester).labelCutout, isNull);
  });

  testWidgets('label renders above the box and is measured', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 40,
            logicalHeight: 20,
            width: 160,
            style: _style,
            label: Text('INV', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    expect(find.text('INV'), findsOneWidget);
    // One pump captures the first frame without a cutout.
    expect(_painter(tester).labelCutout, isNull);
    // The MeasureSize render box schedules a post-frame callback that then
    // setStates → on the next pump the painter receives the cutout.
    await tester.pump();
    final cutout = _painter(tester).labelCutout;
    expect(cutout, isNotNull);
    expect(cutout!.left, 2); // default labelLeftInset
    expect(cutout.width, greaterThan(0));
    expect(cutout.height, 1);
  });

  testWidgets('labelLeftInset is honored', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 40,
            logicalHeight: 20,
            width: 160,
            style: _style,
            labelLeftInset: 5,
            label: Text('X', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(_painter(tester).labelCutout!.left, 5);
  });

  testWidgets('removing the label clears the cutout', (tester) async {
    Widget build({Widget? label}) => Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: PixelBox(
              logicalWidth: 40,
              logicalHeight: 20,
              width: 160,
              style: _style,
              label: label,
            ),
          ),
        );

    await tester.pumpWidget(
      build(label: const Text('INV', textDirection: TextDirection.ltr)),
    );
    await tester.pump();
    expect(_painter(tester).labelCutout, isNotNull);

    await tester.pumpWidget(build());
    await tester.pump();
    expect(_painter(tester).labelCutout, isNull);
  });
}
