import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  const style = PixelShapeStyle(
    corners: PixelCorners.md,
    fillColor: Color(0xFFFF0000),
  );

  testWidgets('PixelBox default size is logical × 4', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 10,
            logicalHeight: 5,
            style: style,
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(PixelBox));
    expect(size.width, 40.0);
    expect(size.height, 20.0);
  });

  testWidgets('PixelBox computes height from width via ratio', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 10,
            logicalHeight: 5,
            style: style,
            width: 100,
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(PixelBox));
    expect(size.width, 100.0);
    expect(size.height, 50.0);
  });

  testWidgets('PixelBox computes width from height via ratio', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 10,
            logicalHeight: 5,
            style: style,
            height: 50,
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(PixelBox));
    expect(size.width, 100.0);
    expect(size.height, 50.0);
  });

  testWidgets('PixelBox uses explicit width and height when both given', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 10,
            logicalHeight: 5,
            style: style,
            width: 200,
            height: 30,
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(PixelBox));
    expect(size.width, 200.0);
    expect(size.height, 30.0);
  });

  testWidgets('PixelBox renders child', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: PixelBox(
            logicalWidth: 10,
            logicalHeight: 5,
            style: style,
            child: Text('hi'),
          ),
        ),
      ),
    );
    expect(find.text('hi'), findsOneWidget);
  });
}
