import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui_tuner/src/widgets/switch/switch_code.dart';
import 'package:pixel_ui_tuner/src/widgets/switch/switch_state.dart';

void main() {
  group('generateSwitchCode', () {
    test('default state emits 3 const styles + PixelSwitch call', () {
      final code = generateSwitchCode(SwitchState());
      expect(code, contains('const onTrack = PixelShapeStyle('));
      expect(code, contains('const offTrack = PixelShapeStyle('));
      expect(code, contains('const thumb = PixelShapeStyle('));
      expect(code, contains('PixelSwitch('));
      expect(code, contains('  value: false,'));
      expect(code, contains('  onChanged: (v) {},'));
      expect(code, contains('  onTrackStyle: onTrack,'));
      expect(code, contains('  offTrackStyle: offTrack,'));
      expect(code, contains('  thumbStyle: thumb,'));
    });

    test('disabledStyle == null omits both const and widget arg', () {
      final code = generateSwitchCode(SwitchState());
      expect(code, isNot(contains('const disabled =')));
      expect(code, isNot(contains('disabledStyle:')));
    });

    test('disabledStyle non-null adds const + widget arg', () {
      final s = SwitchState();
      s.setDisabled(s.thumb);
      final code = generateSwitchCode(s);
      expect(code, contains('const disabled = PixelShapeStyle('));
      expect(code, contains('  disabledStyle: disabled,'));
    });

    test('previewValue=true is reflected in `value:`', () {
      final s = SwitchState();
      s.togglePreviewValue();
      final code = generateSwitchCode(s);
      expect(code, contains('  value: true,'));
    });
  });
}
