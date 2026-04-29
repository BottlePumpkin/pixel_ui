import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui_tuner/src/widgets/slider/slider_code.dart';
import 'package:pixel_ui_tuner/src/widgets/slider/slider_state.dart';

void main() {
  group('generateSliderCode', () {
    test('default state emits track/fill/thumb consts + PixelSlider call', () {
      final code = generateSliderCode(SliderState());
      expect(code, contains('const track = PixelShapeStyle('));
      expect(code, contains('const fill = PixelShapeStyle('));
      expect(code, contains('const thumb = PixelShapeStyle('));
      expect(code, contains('PixelSlider('));
      expect(code, contains('  value: 0.5,'));
      expect(code, contains('  min: 0.0,'));
      expect(code, contains('  max: 1.0,'));
      expect(code, contains('  trackStyle: track,'));
      expect(code, contains('  fillStyle: fill,'));
      expect(code, contains('  thumbStyle: thumb,'));
    });

    test('continuous (divisions=null) omits divisions arg', () {
      final code = generateSliderCode(SliderState());
      expect(code, isNot(contains('divisions:')));
    });

    test('discrete divisions emits divisions arg', () {
      final s = SliderState();
      s.setDivisions(4);
      final code = generateSliderCode(s);
      expect(code, contains('  divisions: 4,'));
    });

    test('disabledStyle == null omits both const and widget arg', () {
      final code = generateSliderCode(SliderState());
      expect(code, isNot(contains('const disabled =')));
      expect(code, isNot(contains('disabledStyle:')));
    });

    test('disabledStyle non-null adds const + widget arg', () {
      final s = SliderState();
      s.setDisabled(s.thumb);
      final code = generateSliderCode(s);
      expect(code, contains('const disabled = PixelShapeStyle('));
      expect(code, contains('  disabledStyle: disabled,'));
    });

    test('previewValue is reflected in `value:`', () {
      final s = SliderState();
      s.setPreviewValue(0.75);
      final code = generateSliderCode(s);
      expect(code, contains('  value: 0.75,'));
    });
  });
}
