import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('divisions snaps drag values to nearest step', (tester) async {
    final values = <double>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: PixelSlider(
                value: 0.0,
                onChanged: (v) => values.add(v),
                min: 0,
                max: 4,
                divisions: 4,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
            ),
          ),
        ),
      ),
    );

    final start = tester.getTopLeft(find.byType(PixelSlider)) + const Offset(10, 8);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(300, 0));
    await tester.pumpAndSettle();
    await gesture.up();

    // All emitted values must be in {0, 1, 2, 3, 4}.
    for (final v in values) {
      expect(v, anyOf(0.0, 1.0, 2.0, 3.0, 4.0),
          reason: 'expected a snapped step, got $v');
    }
    // And at least one step should have changed.
    expect(values, isNotEmpty);
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
            child: SizedBox(
              width: 200,
              child: PixelSlider(
                value: 0.5,
                onChanged: (_) {},
                enabled: false,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
                disabledStyle: disabled,
              ),
            ),
          ),
        ),
      ),
    );
    final painters = _painters(tester);
    // Track is the first painter (drawn first under fill+thumb). When
    // disabled with explicit disabledStyle, the track adopts disabledStyle.
    expect(painters.any((p) => p.style == disabled), isTrue);
  });

  testWidgets('falls back to 50% opacity when disabled and no disabledStyle',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: PixelSlider(
                value: 0.5,
                onChanged: (_) {},
                enabled: false,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
              ),
            ),
          ),
        ),
      ),
    );
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(PixelSlider),
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
    expect(
      find.descendant(
        of: find.byType(PixelSlider),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  testWidgets('Arrow Right increments by keyboardStep when focused',
      (tester) async {
    double current = 0.5;
    final focus = FocusNode();
    addTearDown(focus.dispose);
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
                  focusNode: focus,
                  autofocus: true,
                ),
              ),
            ),
          ),
        );
      }),
    );
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    final before = current;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(current, greaterThan(before));
  });

  testWidgets('Arrow Left decrements by keyboardStep', (tester) async {
    double current = 0.5;
    final focus = FocusNode();
    addTearDown(focus.dispose);
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
                  focusNode: focus,
                  autofocus: true,
                ),
              ),
            ),
          ),
        );
      }),
    );
    await tester.pumpAndSettle();
    final before = current;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(current, lessThan(before));
  });

  testWidgets('PageUp moves more than ArrowRight', (tester) async {
    double current = 0.0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
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
                  focusNode: focus,
                  autofocus: true,
                ),
              ),
            ),
          ),
        );
      }),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    final afterArrow = current;
    current = 0.0;
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pumpAndSettle();
    expect(current, greaterThan(afterArrow));
  });

  testWidgets('exposes slider semantics with value text and label',
      (tester) async {
    final handle = tester.ensureSemantics();
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
                semanticsLabel: '볼륨',
              ),
            ),
          ),
        ),
      ),
    );
    final node = tester.getSemantics(
      find
          .descendant(
            of: find.byType(PixelSlider),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(node, matchesSemantics(
      label: '볼륨',
      value: '50%',
      isSlider: true,
      hasEnabledState: true,
      isEnabled: true,
      isFocusable: true,
      hasTapAction: true,
      hasFocusAction: true,
      hasIncreaseAction: true,
      hasDecreaseAction: true,
      hasScrollLeftAction: true,
      hasScrollRightAction: true,
    ));
    handle.dispose();
  });

  testWidgets('semanticsValueText overrides default formatter',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              child: PixelSlider(
                value: 3,
                onChanged: (_) {},
                min: 1,
                max: 5,
                divisions: 4,
                trackStyle: _track,
                fillStyle: _fill,
                thumbStyle: _thumb,
                semanticsLabel: '난이도',
                semanticsValueText: (v) => '난이도 ${v.round()}',
              ),
            ),
          ),
        ),
      ),
    );
    final node = tester.getSemantics(
      find
          .descendant(
            of: find.byType(PixelSlider),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(node, matchesSemantics(
      label: '난이도',
      value: '난이도 3',
      isSlider: true,
      hasEnabledState: true,
      isEnabled: true,
      isFocusable: true,
      hasTapAction: true,
      hasFocusAction: true,
      hasIncreaseAction: true,
      hasDecreaseAction: true,
      hasScrollLeftAction: true,
      hasScrollRightAction: true,
    ));
    handle.dispose();
  });

  testWidgets('keyboard inactive when disabled', (tester) async {
    double current = 0.5;
    final focus = FocusNode();
    addTearDown(focus.dispose);
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
                  enabled: false,
                  trackStyle: _track,
                  fillStyle: _fill,
                  thumbStyle: _thumb,
                  focusNode: focus,
                  autofocus: true,
                ),
              ),
            ),
          ),
        );
      }),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(current, 0.5);
  });

  group('theme pickup', () {
    testWidgets('uses PixelSliderTheme.* when props omitted', (tester) async {
      const themedTrack = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFAAAAAA),
      );
      const themedFill = PixelShapeStyle(
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
            sliderTheme: const PixelSliderTheme(
              trackStyle: themedTrack,
              fillStyle: themedFill,
              thumbStyle: themedThumb,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: PixelSlider(
                  value: 0.5,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      final painters = _painters(tester);
      expect(painters.any((p) => p.style == themedTrack), isTrue);
      expect(painters.any((p) => p.style == themedFill), isTrue);
      expect(painters.any((p) => p.style == themedThumb), isTrue);
    });

    testWidgets('explicit prop wins over theme', (tester) async {
      const themedThumb = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFAAAAAA),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            sliderTheme: const PixelSliderTheme(
              trackStyle: _track,
              fillStyle: _fill,
              thumbStyle: themedThumb,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: PixelSlider(
                  value: 0.5,
                  onChanged: (_) {},
                  thumbStyle: _thumb,
                ),
              ),
            ),
          ),
        ),
      );
      expect(_painters(tester).any((p) => p.style == _thumb), isTrue);
      expect(_painters(tester).any((p) => p.style == themedThumb), isFalse);
    });

    testWidgets('asserts when required style missing from prop and theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: PixelSlider(
                  value: 0.5,
                  onChanged: (_) {},
                ),
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
            sliderTheme: const PixelSliderTheme(
              trackStyle: _track,
              fillStyle: _fill,
              thumbStyle: _thumb,
              disabledStyle: themedDisabled,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: PixelSlider(
                  value: 0.5,
                  onChanged: (_) {},
                  enabled: false,
                ),
              ),
            ),
          ),
        ),
      );
      expect(_painters(tester).any((p) => p.style == themedDisabled), isTrue);
    });
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
