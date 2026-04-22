import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  const normalStyle = PixelShapeStyle(
    corners: PixelCorners.md,
    fillColor: Color(0xFF00FF00),
  );
  const pressedStyle = PixelShapeStyle(
    corners: PixelCorners.md,
    fillColor: Color(0xFF008800),
  );

  testWidgets('PixelButton invokes onPressed on tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelButton(
            logicalWidth: 10,
            logicalHeight: 5,
            normalStyle: normalStyle,
            onPressed: () => tapped = true,
            child: const Text('tap'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('PixelButton disabled when onPressed is null', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelButton(
            logicalWidth: 10,
            logicalHeight: 5,
            normalStyle: normalStyle,
            onPressed: null,
            child: const Text('disabled'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelButton));
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('PixelButton exposes semanticsLabel', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelButton(
            logicalWidth: 10,
            logicalHeight: 5,
            normalStyle: normalStyle,
            onPressed: () {},
            semanticsLabel: 'My Button',
            child: const Text('x'),
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(PixelButton)),
      matchesSemantics(label: 'My Button', isButton: true, isEnabled: true, hasEnabledState: true),
    );
    handle.dispose();
  });

  testWidgets('PixelButton switches to pressed style on tap down', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelButton(
            logicalWidth: 10,
            logicalHeight: 5,
            normalStyle: normalStyle,
            pressedStyle: pressedStyle,
            onPressed: () {},
            child: const Text('p'),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PixelButton)));
    await tester.pump();
    final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint).first);
    final painter = customPaint.painter! as PixelShapePainter;
    expect(painter.style, pressedStyle);
    await gesture.up();
  });
}
