import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _boxStyle = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFFFF0000),
);
const _normalStyle = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF00AA00),
);
const _pressedStyle = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF007700),
);
const _disabledStyle = PixelShapeStyle(
  corners: PixelCorners.sm,
  fillColor: Color(0xFF888888),
);

void main() {
  group('PixelBoxTheme', () {
    test('copyWith replaces style', () {
      const a = PixelBoxTheme(style: _boxStyle);
      final b = a.copyWith(style: _normalStyle);
      expect(b.style, _normalStyle);
    });

    test('copyWith preserves omitted fields', () {
      const a = PixelBoxTheme(style: _boxStyle);
      final b = a.copyWith();
      expect(b.style, _boxStyle);
    });

    test('lerp snaps at t=0.5', () {
      const a = PixelBoxTheme(style: _boxStyle);
      const b = PixelBoxTheme(style: _normalStyle);
      expect(a.lerp(b, 0.0).style, _boxStyle);
      expect(a.lerp(b, 0.49).style, _boxStyle);
      expect(a.lerp(b, 0.5).style, _normalStyle);
      expect(a.lerp(b, 1.0).style, _normalStyle);
    });

    test('lerp returns self when other is null', () {
      const a = PixelBoxTheme(style: _boxStyle);
      expect(a.lerp(null, 0.5), same(a));
    });
  });

  group('PixelButtonTheme', () {
    const a = PixelButtonTheme(
      normalStyle: _normalStyle,
      pressedStyle: _pressedStyle,
      disabledStyle: _disabledStyle,
    );

    test('copyWith replaces one field', () {
      final b = a.copyWith(pressedStyle: _boxStyle);
      expect(b.normalStyle, _normalStyle);
      expect(b.pressedStyle, _boxStyle);
      expect(b.disabledStyle, _disabledStyle);
    });

    test('lerp snaps at t=0.5', () {
      const other = PixelButtonTheme(normalStyle: _boxStyle);
      final mid = a.lerp(other, 0.5);
      expect(mid.normalStyle, _boxStyle);
    });
  });

  group('PixelListTileTheme', () {
    const padA = EdgeInsets.all(8);
    const padB = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

    const a = PixelListTileTheme(
      style: _normalStyle,
      pressedStyle: _pressedStyle,
      disabledStyle: _disabledStyle,
      contentPadding: padA,
      slotGap: 8,
    );

    test('copyWith replaces one field, preserves others', () {
      final b = a.copyWith(contentPadding: padB);
      expect(b.style, _normalStyle);
      expect(b.pressedStyle, _pressedStyle);
      expect(b.disabledStyle, _disabledStyle);
      expect(b.contentPadding, padB);
      expect(b.slotGap, 8);
    });

    test('lerp snaps at t=0.5', () {
      const other = PixelListTileTheme(style: _boxStyle, slotGap: 16);
      expect(a.lerp(other, 0.0).style, _normalStyle);
      expect(a.lerp(other, 0.49).style, _normalStyle);
      expect(a.lerp(other, 0.5).style, _boxStyle);
      expect(a.lerp(other, 0.5).slotGap, 16);
    });

    test('lerp returns self when other is null', () {
      expect(a.lerp(null, 0.5), same(a));
    });
  });

  group('PixelSwitchTheme', () {
    const dimmed = PixelShapeStyle(
      corners: PixelCorners.sm,
      fillColor: Color(0xFF222222),
    );

    const a = PixelSwitchTheme(
      onTrackStyle: _normalStyle,
      offTrackStyle: _pressedStyle,
      thumbStyle: _boxStyle,
      disabledStyle: _disabledStyle,
    );

    test('copyWith replaces one field, preserves others', () {
      final b = a.copyWith(disabledStyle: dimmed);
      expect(b.onTrackStyle, _normalStyle);
      expect(b.offTrackStyle, _pressedStyle);
      expect(b.thumbStyle, _boxStyle);
      expect(b.disabledStyle, dimmed);
    });

    test('lerp snaps at t=0.5', () {
      const other = PixelSwitchTheme(onTrackStyle: dimmed);
      expect(a.lerp(other, 0.0).onTrackStyle, _normalStyle);
      expect(a.lerp(other, 0.49).onTrackStyle, _normalStyle);
      expect(a.lerp(other, 0.5).onTrackStyle, dimmed);
    });

    test('lerp returns self when other is null', () {
      expect(a.lerp(null, 0.5), same(a));
    });
  });

  group('PixelTheme (umbrella)', () {
    test('copyWith replaces box and button', () {
      const a = PixelTheme();
      final b = a.copyWith(
        box: const PixelBoxTheme(style: _boxStyle),
        button: const PixelButtonTheme(normalStyle: _normalStyle),
      );
      expect(b.box?.style, _boxStyle);
      expect(b.button?.normalStyle, _normalStyle);
    });

    test('lerp snaps children at t=0.5', () {
      const a = PixelTheme(box: PixelBoxTheme(style: _boxStyle));
      const b = PixelTheme(box: PixelBoxTheme(style: _normalStyle));
      final mid = a.lerp(b, 0.6);
      expect(mid.box?.style, _normalStyle);
    });

    test('copyWith replaces listTile slot', () {
      const a = PixelTheme();
      final b = a.copyWith(
        listTile: const PixelListTileTheme(style: _boxStyle),
      );
      expect(b.listTile?.style, _boxStyle);
    });
  });

  group('pixelUiTheme factory', () {
    test('registers three extensions on fresh ThemeData', () {
      final theme = pixelUiTheme(
        pixelTheme: const PixelTheme(),
        boxTheme: const PixelBoxTheme(style: _boxStyle),
        buttonTheme: const PixelButtonTheme(normalStyle: _normalStyle),
      );
      expect(theme.extension<PixelTheme>(), isNotNull);
      expect(theme.extension<PixelBoxTheme>()?.style, _boxStyle);
      expect(theme.extension<PixelButtonTheme>()?.normalStyle, _normalStyle);
    });

    test('preserves unrelated extensions on the base theme', () {
      final base = ThemeData().copyWith(
        extensions: const <ThemeExtension<dynamic>>[_MarkerExtension()],
      );
      final theme = pixelUiTheme(
        base: base,
        boxTheme: const PixelBoxTheme(style: _boxStyle),
      );
      expect(theme.extension<_MarkerExtension>(), isNotNull);
      expect(theme.extension<PixelBoxTheme>(), isNotNull);
    });

    test('replaces existing pixel extensions on the base theme', () {
      final base = pixelUiTheme(
        boxTheme: const PixelBoxTheme(style: _boxStyle),
      );
      final overridden = pixelUiTheme(
        base: base,
        boxTheme: const PixelBoxTheme(style: _normalStyle),
      );
      expect(overridden.extension<PixelBoxTheme>()?.style, _normalStyle);
    });

    test('derives box/button from umbrella when explicit not given', () {
      final theme = pixelUiTheme(
        pixelTheme: const PixelTheme(
          box: PixelBoxTheme(style: _boxStyle),
          button: PixelButtonTheme(normalStyle: _normalStyle),
        ),
      );
      expect(theme.extension<PixelBoxTheme>()?.style, _boxStyle);
      expect(theme.extension<PixelButtonTheme>()?.normalStyle, _normalStyle);
    });

    test('explicit boxTheme overrides umbrella.box', () {
      final theme = pixelUiTheme(
        pixelTheme: const PixelTheme(box: PixelBoxTheme(style: _boxStyle)),
        boxTheme: const PixelBoxTheme(style: _normalStyle),
      );
      expect(theme.extension<PixelBoxTheme>()?.style, _normalStyle);
    });

    test('registers PixelListTileTheme when listTileTheme provided', () {
      final theme = pixelUiTheme(
        listTileTheme: const PixelListTileTheme(style: _boxStyle),
      );
      expect(theme.extension<PixelListTileTheme>()?.style, _boxStyle);
    });

    test('derives listTile from umbrella when explicit not given', () {
      final theme = pixelUiTheme(
        pixelTheme: const PixelTheme(
          listTile: PixelListTileTheme(style: _boxStyle),
        ),
      );
      expect(theme.extension<PixelListTileTheme>()?.style, _boxStyle);
    });

    test('explicit listTileTheme overrides umbrella.listTile', () {
      final theme = pixelUiTheme(
        pixelTheme: const PixelTheme(
          listTile: PixelListTileTheme(style: _boxStyle),
        ),
        listTileTheme: const PixelListTileTheme(style: _normalStyle),
      );
      expect(theme.extension<PixelListTileTheme>()?.style, _normalStyle);
    });
  });

  group('context.pixelTheme<T>()', () {
    testWidgets('resolves PixelBoxTheme from ancestor Theme', (tester) async {
      late PixelBoxTheme? resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            boxTheme: const PixelBoxTheme(style: _boxStyle),
          ),
          home: Builder(
            builder: (context) {
              resolved = context.pixelTheme<PixelBoxTheme>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved?.style, _boxStyle);
    });

    testWidgets('returns null when extension absent', (tester) async {
      late PixelBoxTheme? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = context.pixelTheme<PixelBoxTheme>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, isNull);
    });
  });

  group('PixelBox theme pickup', () {
    testWidgets('uses PixelBoxTheme.style when style prop omitted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            boxTheme: const PixelBoxTheme(style: _boxStyle),
          ),
          home: const Center(
            child: PixelBox(logicalWidth: 10, logicalHeight: 5),
          ),
        ),
      );
      final painter = _pixelPainter(tester);
      expect(painter.style, _boxStyle);
    });

    testWidgets('explicit style prop wins over theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            boxTheme: const PixelBoxTheme(style: _boxStyle),
          ),
          home: const Center(
            child: PixelBox(
              logicalWidth: 10,
              logicalHeight: 5,
              style: _normalStyle,
            ),
          ),
        ),
      );
      final painter = _pixelPainter(tester);
      expect(painter.style, _normalStyle);
    });

    testWidgets('asserts when both style prop and theme absent', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: PixelBox(logicalWidth: 10, logicalHeight: 5),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('PixelButton theme pickup', () {
    testWidgets('uses PixelButtonTheme.normalStyle when normalStyle prop omitted',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            buttonTheme: const PixelButtonTheme(normalStyle: _normalStyle),
          ),
          home: Center(
            child: PixelButton(
              logicalWidth: 10,
              logicalHeight: 5,
              onPressed: () {},
              child: const Text('x'),
            ),
          ),
        ),
      );
      final painter = _pixelPainter(tester);
      expect(painter.style, _normalStyle);
    });

    testWidgets('inherits pressedStyle from theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            buttonTheme: const PixelButtonTheme(
              normalStyle: _normalStyle,
              pressedStyle: _pressedStyle,
            ),
          ),
          home: Center(
            child: PixelButton(
              logicalWidth: 10,
              logicalHeight: 5,
              onPressed: () {},
              child: const Text('p'),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(tester.getCenter(find.byType(PixelButton)));
      await tester.pump();
      final painter = _pixelPainter(tester);
      expect(painter.style, _pressedStyle);
      await gesture.up();
    });

    testWidgets('inherits disabledStyle from theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _ThemeWrapper(
            button: PixelButtonTheme(
              normalStyle: _normalStyle,
              disabledStyle: _disabledStyle,
            ),
            child: Center(
              child: PixelButton(
                logicalWidth: 10,
                logicalHeight: 5,
                onPressed: null,
                child: Text('d'),
              ),
            ),
          ),
        ),
      );
      final painter = _pixelPainter(tester);
      expect(painter.style, _disabledStyle);
    });

    testWidgets('explicit normalStyle prop wins over theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            buttonTheme: const PixelButtonTheme(normalStyle: _disabledStyle),
          ),
          home: Center(
            child: PixelButton(
              logicalWidth: 10,
              logicalHeight: 5,
              normalStyle: _normalStyle,
              onPressed: () {},
              child: const Text('x'),
            ),
          ),
        ),
      );
      final painter = _pixelPainter(tester);
      expect(painter.style, _normalStyle);
    });

    testWidgets('asserts when both normalStyle prop and theme absent',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PixelButton(
              logicalWidth: 10,
              logicalHeight: 5,
              onPressed: () {},
              child: const Text('x'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });
}

PixelShapePainter _pixelPainter(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelBox),
    matching: find.byType(CustomPaint),
  );
  final paints = tester.widgetList<CustomPaint>(finder);
  for (final paint in paints) {
    final painter = paint.painter;
    if (painter is PixelShapePainter) return painter;
  }
  throw StateError('No PixelShapePainter found in PixelBox subtree');
}

class _MarkerExtension extends ThemeExtension<_MarkerExtension> {
  const _MarkerExtension();

  @override
  ThemeExtension<_MarkerExtension> copyWith() => this;

  @override
  ThemeExtension<_MarkerExtension> lerp(
    covariant ThemeExtension<_MarkerExtension>? other,
    double t,
  ) =>
      this;
}

class _ThemeWrapper extends StatelessWidget {
  const _ThemeWrapper({required this.button, required this.child});

  final PixelButtonTheme button;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: pixelUiTheme(buttonTheme: button),
      child: child,
    );
  }
}
