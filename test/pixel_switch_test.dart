import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('renders thumb with thumbStyle', (tester) async {
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
    expect(painters.length, greaterThanOrEqualTo(2));
    expect(painters.any((p) => p.style == _thumb), isTrue);
  });

  testWidgets('tap toggles value via onChanged', (tester) async {
    bool? newValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: false,
              onChanged: (v) => newValue = v,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelSwitch));
    await tester.pumpAndSettle();
    expect(newValue, isTrue);
  });

  testWidgets('tap is a no-op when onChanged is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: false,
              onChanged: null,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelSwitch), warnIfMissed: false);
    await tester.pumpAndSettle();
    // No exception, no callback fired (no callback exists).
    expect(true, isTrue);
  });

  testWidgets('thumb slides from left (off) to right (on)', (tester) async {
    Widget build(bool v) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelSwitch(
                value: v,
                onChanged: (_) {},
                onTrackStyle: _onTrack,
                offTrackStyle: _offTrack,
                thumbStyle: _thumb,
              ),
            ),
          ),
        );

    await tester.pumpWidget(build(false));
    await tester.pumpAndSettle();
    final offThumb = _thumbCenter(tester);

    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();
    final onThumb = _thumbCenter(tester);

    expect(onThumb.dx, greaterThan(offThumb.dx));
  });

  testWidgets('exposes switch semantics with toggled state', (tester) async {
    final handle = tester.ensureSemantics();
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
              semanticsLabel: '효과음',
            ),
          ),
        ),
      ),
    );
    final node = tester.getSemantics(
      find
          .descendant(
            of: find.byType(PixelSwitch),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(node, matchesSemantics(
      label: '효과음',
      isToggled: true,
      hasToggledState: true,
      hasEnabledState: true,
      isEnabled: true,
      hasTapAction: true,
    ));
    handle.dispose();
  });

  testWidgets('Space toggles when focused', (tester) async {
    bool? newValue;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: false,
              onChanged: (v) => newValue = v,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
              focusNode: focus,
              autofocus: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(newValue, isTrue);
  });

  testWidgets('Enter toggles when focused', (tester) async {
    bool? newValue;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: true,
              onChanged: (v) => newValue = v,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
              focusNode: focus,
              autofocus: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(newValue, isFalse);
  });

  testWidgets('uses disabledStyle when enabled is false and disabledStyle given',
      (tester) async {
    const disabled = PixelShapeStyle(
      corners: PixelCorners.sm,
      fillColor: Color(0xFF333333),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: true,
              onChanged: (_) {},
              enabled: false,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
              disabledStyle: disabled,
            ),
          ),
        ),
      ),
    );
    final painters = _painters(tester);
    expect(painters.first.style, disabled);
  });

  testWidgets('falls back to 50% opacity when disabled and no disabledStyle',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: true,
              onChanged: (_) {},
              enabled: false,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
        ),
      ),
    );
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(PixelSwitch),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('enabled true → no Opacity wrapper', (tester) async {
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
    expect(
      find.descendant(
        of: find.byType(PixelSwitch),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  testWidgets('disabled blocks tap', (tester) async {
    bool? newValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelSwitch(
              value: false,
              onChanged: (v) => newValue = v,
              enabled: false,
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PixelSwitch), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(newValue, isNull);
  });

  group('theme pickup', () {
    testWidgets('uses PixelSwitchTheme.* when props omitted', (tester) async {
      const themedOn = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFAAAAAA),
      );
      const themedOff = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFBBBBBB),
      );
      const themedThumb = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFCCCCCC),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            switchTheme: const PixelSwitchTheme(
              onTrackStyle: themedOn,
              offTrackStyle: themedOff,
              thumbStyle: themedThumb,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: PixelSwitch(
                value: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      final painters = _painters(tester);
      expect(painters.first.style, themedOn);
      expect(painters.any((p) => p.style == themedThumb), isTrue);
    });

    testWidgets('explicit prop wins over theme', (tester) async {
      const themedOn = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFAAAAAA),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            switchTheme: const PixelSwitchTheme(
              onTrackStyle: themedOn,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: PixelSwitch(
                value: true,
                onChanged: (_) {},
                onTrackStyle: _onTrack,
              ),
            ),
          ),
        ),
      );
      expect(_painters(tester).first.style, _onTrack);
    });

    testWidgets('asserts when required style missing from prop and theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelSwitch(
                value: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('inherits disabledStyle from theme', (tester) async {
      const themedDisabled = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF666666),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            switchTheme: const PixelSwitchTheme(
              onTrackStyle: _onTrack,
              offTrackStyle: _offTrack,
              thumbStyle: _thumb,
              disabledStyle: themedDisabled,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: PixelSwitch(
                value: true,
                onChanged: (_) {},
                enabled: false,
              ),
            ),
          ),
        ),
      );
      expect(_painters(tester).first.style, themedDisabled);
    });
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

Offset _thumbCenter(WidgetTester tester) {
  // The thumb is the inner CustomPaint whose painter style equals the
  // configured thumb style. Locate by matching painter.style.
  final finder = find.descendant(
    of: find.byType(PixelSwitch),
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
