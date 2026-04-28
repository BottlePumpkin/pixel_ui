import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _style = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF333A4D),
);

void main() {
  testWidgets('renders title and contains a PixelBox', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: Text('효과음', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    expect(find.text('효과음'), findsOneWidget);
    expect(find.byType(PixelBox), findsOneWidget);
  });
}
