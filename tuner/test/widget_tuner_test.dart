import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui_tuner/src/widget_tuner.dart';

class _StubTuner implements WidgetTuner {
  bool disposed = false;
  int controlsBuilds = 0;
  int previewBuilds = 0;
  int codeBuilds = 0;

  @override
  String get name => 'Stub';

  @override
  Widget get pixelIcon => const SizedBox.shrink();

  @override
  Widget buildControls(BuildContext context) {
    controlsBuilds++;
    return const SizedBox.shrink();
  }

  @override
  Widget buildPreview(BuildContext context) {
    previewBuilds++;
    return const SizedBox.shrink();
  }

  @override
  Widget buildCode(BuildContext context) {
    codeBuilds++;
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  test('WidgetTuner is implementable as a contract', () {
    final t = _StubTuner();
    expect(t.name, 'Stub');
    expect(t.pixelIcon, isA<Widget>());
    expect(t.disposed, isFalse);
    t.dispose();
    expect(t.disposed, isTrue);
  });

  testWidgets('WidgetTuner build* methods can be embedded in a widget tree',
      (tester) async {
    final t = _StubTuner();
    addTearDown(t.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Column(children: [
              t.buildControls(ctx),
              t.buildPreview(ctx),
              t.buildCode(ctx),
            ]),
          ),
        ),
      ),
    );
    expect(t.controlsBuilds, greaterThanOrEqualTo(1));
    expect(t.previewBuilds, greaterThanOrEqualTo(1));
    expect(t.codeBuilds, greaterThanOrEqualTo(1));
  });
}
