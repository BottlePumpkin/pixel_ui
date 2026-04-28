import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

  testWidgets('uses disabledStyle when enabled is false and disabledStyle given',
      (tester) async {
    const disabledStyle = PixelShapeStyle(
      corners: PixelCorners.sm,
      fillColor: Color(0xFF888888),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            disabledStyle: disabledStyle,
            enabled: false,
            title: Text('x', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    final painter = _pixelPainter(tester);
    expect(painter.style, disabledStyle);
  });

  testWidgets('falls back to 50% opacity when disabled and no disabledStyle',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            enabled: false,
            title: Text('x', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(PixelListTile),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('enabled true → no opacity wrapper', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: Text('x', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(PixelListTile),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  testWidgets('invokes onTap on tap when enabled', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: const Text('t', textDirection: TextDirection.ltr),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelListTile));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('does not invoke onTap when enabled is false', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            enabled: false,
            title: const Text('t', textDirection: TextDirection.ltr),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelListTile));
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('switches to pressedStyle on tap-down', (tester) async {
    const pressed = PixelShapeStyle(
      corners: PixelCorners.sm,
      fillColor: Color(0xFF222222),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            pressedStyle: pressed,
            title: const Text('t', textDirection: TextDirection.ltr),
            onTap: () {},
          ),
        ),
      ),
    );
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(PixelListTile)));
    await tester.pump();
    expect(_pixelPainter(tester).style, pressed);
    await gesture.up();
  });

  testWidgets('button semantics when onTap given', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: const Text('t', textDirection: TextDirection.ltr),
            onTap: () {},
            semanticsLabel: 'Profile',
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(
        find.descendant(
          of: find.byType(PixelListTile),
          matching: find.byType(Semantics),
        ).first,
      ),
      matchesSemantics(
        label: 'Profile',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('no button semantics when onTap is null', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PixelListTile(
            style: _style,
            title: Text('t', textDirection: TextDirection.ltr),
          ),
        ),
      ),
    );
    final node = tester.getSemantics(
      find.descendant(
        of: find.byType(PixelListTile),
        matching: find.byType(Semantics),
      ).first,
    );
    expect(node.hasFlag(SemanticsFlag.isButton), isFalse);
    handle.dispose();
  });

  group('theme pickup', () {
    testWidgets('uses PixelListTileTheme.style when style prop omitted',
        (tester) async {
      const themed = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF111111),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            listTileTheme: const PixelListTileTheme(style: themed),
          ),
          home: const Scaffold(
            body: PixelListTile(
              title: Text('t', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );
      expect(_pixelPainter(tester).style, themed);
    });

    testWidgets('explicit style prop wins over theme', (tester) async {
      const themed = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF111111),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            listTileTheme: const PixelListTileTheme(style: themed),
          ),
          home: const Scaffold(
            body: PixelListTile(
              style: _style,
              title: Text('t', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );
      expect(_pixelPainter(tester).style, _style);
    });

    testWidgets('asserts when both style prop and theme absent',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PixelListTile(
              title: Text('t', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('inherits pressedStyle from theme', (tester) async {
      const pressed = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF222222),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            listTileTheme: const PixelListTileTheme(
              style: _style,
              pressedStyle: pressed,
            ),
          ),
          home: Scaffold(
            body: PixelListTile(
              title: const Text('t', textDirection: TextDirection.ltr),
              onTap: () {},
            ),
          ),
        ),
      );
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(PixelListTile)));
      await tester.pump();
      expect(_pixelPainter(tester).style, pressed);
      await gesture.up();
    });

    testWidgets('inherits disabledStyle from theme', (tester) async {
      const disabled = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF888888),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: _ListTileThemeWrapper(
            theme: PixelListTileTheme(
              style: _style,
              disabledStyle: disabled,
            ),
            child: Scaffold(
              body: PixelListTile(
                enabled: false,
                title: Text('t', textDirection: TextDirection.ltr),
              ),
            ),
          ),
        ),
      );
      expect(_pixelPainter(tester).style, disabled);
    });

    testWidgets('inherits contentPadding and slotGap from theme',
        (tester) async {
      const themePadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            listTileTheme: const PixelListTileTheme(
              style: _style,
              contentPadding: themePadding,
              slotGap: 30,
            ),
          ),
          home: const Scaffold(
            body: PixelListTile(
              leading: Text('L', textDirection: TextDirection.ltr),
              title: Text('T', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );
      final lRight = tester.getTopRight(find.text('L')).dx;
      final tLeft = tester.getTopLeft(find.text('T')).dx;
      expect(tLeft - lRight, greaterThanOrEqualTo(30));
    });
  });
}

PixelShapePainter _pixelPainter(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelListTile),
    matching: find.byType(CustomPaint),
  );
  return tester
      .widgetList<CustomPaint>(finder)
      .map((p) => p.painter)
      .whereType<PixelShapePainter>()
      .first;
}

class _ListTileThemeWrapper extends StatelessWidget {
  const _ListTileThemeWrapper({required this.theme, required this.child});
  final PixelListTileTheme theme;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: pixelUiTheme(listTileTheme: theme),
      child: child,
    );
  }
}
