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

  testWidgets('renders leading + title + trailing in left-to-right order',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            leading: Text('L', textDirection: TextDirection.ltr),
            title: Text('T', textDirection: TextDirection.ltr),
            trailing: Text('R', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    final lx = tester.getCenter(find.text('L')).dx;
    final tx = tester.getCenter(find.text('T')).dx;
    final rx = tester.getCenter(find.text('R')).dx;
    expect(lx, lessThan(tx));
    expect(tx, lessThan(rx));
  });

  testWidgets('subtitle stacks below title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: Text('T', textDirection: TextDirection.ltr),
            subtitle: Text('S', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    final ty = tester.getCenter(find.text('T')).dy;
    final sy = tester.getCenter(find.text('S')).dy;
    expect(ty, lessThan(sy));
  });

  testWidgets('omitted slots do not render extra widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: Text('T', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    expect(find.text('T'), findsOneWidget);
    expect(find.text('L'), findsNothing);
    expect(find.text('R'), findsNothing);
    expect(find.text('S'), findsNothing);
  });
}
