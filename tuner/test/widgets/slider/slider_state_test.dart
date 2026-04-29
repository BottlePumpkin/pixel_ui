import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui_tuner/src/widgets/slider/slider_state.dart';

void main() {
  group('SliderState', () {
    test('initial defaults: 0..1, no divisions, previewValue 0.5', () {
      final s = SliderState();
      expect(s.min, 0.0);
      expect(s.max, 1.0);
      expect(s.divisions, isNull);
      expect(s.previewValue, 0.5);
      expect(s.disabledStyle, isNull);
    });

    test('setMin clamps previewValue into the new range', () {
      final s = SliderState();
      s.setPreviewValue(0.2);
      s.setMin(0.5);
      expect(s.min, 0.5);
      expect(s.previewValue, 0.5); // clamped up
    });

    test('setMax clamps previewValue down', () {
      final s = SliderState();
      s.setPreviewValue(0.9);
      s.setMax(0.4);
      expect(s.max, 0.4);
      expect(s.previewValue, 0.4); // clamped down
    });

    test('setDivisions accepts null and integer', () {
      final s = SliderState();
      s.setDivisions(4);
      expect(s.divisions, 4);
      s.setDivisions(null);
      expect(s.divisions, isNull);
    });

    test('setPreviewValue clamps to [min, max]', () {
      final s = SliderState();
      s.setPreviewValue(2.0);
      expect(s.previewValue, 1.0);
      s.setPreviewValue(-1.0);
      expect(s.previewValue, 0.0);
    });

    test('all setters notify listeners', () {
      final s = SliderState();
      var n = 0;
      s.addListener(() => n++);
      s.setMin(0.1);
      s.setMax(0.9);
      s.setDivisions(5);
      s.setPreviewValue(0.5);
      expect(n, 4);
    });
  });
}
