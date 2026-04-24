import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';

const _boxStyle = PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: Color(0xFFFF0000),
);

/// Minimal marker painter used to assert that a custom builder ran.
class _MarkerPainter extends CustomPainter {
  _MarkerPainter({
    required this.style,
    required this.logicalWidth,
    required this.logicalHeight,
  });

  final PixelShapeStyle style;
  final int logicalWidth;
  final int logicalHeight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = style.fillColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

CustomPaint _paintOf(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(PixelBox),
    matching: find.byType(CustomPaint),
  );
  return tester.widgetList<CustomPaint>(finder).firstWhere(
        (p) => p.painter != null,
        orElse: () =>
            throw StateError('No CustomPaint with painter found in PixelBox'),
      );
}

void main() {
  group('PixelShapePainterBuilder injection', () {
    testWidgets('defaults to PixelShapePainter when no builder is set',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: PixelBox(
              logicalWidth: 10,
              logicalHeight: 5,
              style: _boxStyle,
            ),
          ),
        ),
      );
      expect(_paintOf(tester).painter, isA<PixelShapePainter>());
    });

    testWidgets('uses PixelBoxTheme.painter when widget prop is null',
        (tester) async {
      _MarkerPainter? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            boxTheme: PixelBoxTheme(
              style: _boxStyle,
              painter: ({
                required int logicalWidth,
                required int logicalHeight,
                required PixelShapeStyle style,
              }) {
                final p = _MarkerPainter(
                  style: style,
                  logicalWidth: logicalWidth,
                  logicalHeight: logicalHeight,
                );
                captured = p;
                return p;
              },
            ),
          ),
          home: const Center(
            child: PixelBox(logicalWidth: 10, logicalHeight: 5),
          ),
        ),
      );
      final painter = _paintOf(tester).painter;
      expect(painter, isA<_MarkerPainter>());
      expect(captured, same(painter));
      expect(captured!.logicalWidth, 10);
      expect(captured!.logicalHeight, 5);
      expect(captured!.style, _boxStyle);
    });

    testWidgets('widget painter prop wins over theme.painter',
        (tester) async {
      _MarkerPainter? fromProp;
      CustomPainter themePainterBuilder({
        required int logicalWidth,
        required int logicalHeight,
        required PixelShapeStyle style,
      }) {
        throw StateError('theme builder should not have been invoked');
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            boxTheme: PixelBoxTheme(
              style: _boxStyle,
              painter: themePainterBuilder,
            ),
          ),
          home: Center(
            child: PixelBox(
              logicalWidth: 8,
              logicalHeight: 4,
              style: _boxStyle,
              painter: ({
                required int logicalWidth,
                required int logicalHeight,
                required PixelShapeStyle style,
              }) {
                final p = _MarkerPainter(
                  style: style,
                  logicalWidth: logicalWidth,
                  logicalHeight: logicalHeight,
                );
                fromProp = p;
                return p;
              },
            ),
          ),
        ),
      );
      expect(_paintOf(tester).painter, same(fromProp));
    });

    testWidgets('builder receives the resolved style (theme fallback path)',
        (tester) async {
      PixelShapeStyle? seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: pixelUiTheme(
            boxTheme: PixelBoxTheme(
              style: _boxStyle,
              painter: ({
                required int logicalWidth,
                required int logicalHeight,
                required PixelShapeStyle style,
              }) {
                seen = style;
                return _MarkerPainter(
                  style: style,
                  logicalWidth: logicalWidth,
                  logicalHeight: logicalHeight,
                );
              },
            ),
          ),
          home: const Center(
            child: PixelBox(logicalWidth: 10, logicalHeight: 5),
          ),
        ),
      );
      expect(seen, _boxStyle);
    });
  });
}
