import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/widgets/switch/switch_state.dart';

void main() {
  group('SwitchState', () {
    test('initial defaults match the README cookbook recipe', () {
      final s = SwitchState();
      expect(s.onTrack.fillColor, const Color(0xFFFFD643));
      expect(s.offTrack.fillColor, const Color(0xFF555E73));
      expect(s.thumb.fillColor, const Color(0xFFFFFFFF));
      expect(s.disabledStyle, isNull);
      expect(s.previewValue, isFalse);
    });

    test('setOnTrack updates and notifies', () {
      final s = SwitchState();
      var n = 0;
      s.addListener(() => n++);
      const next = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF112233),
      );
      s.setOnTrack(next);
      expect(s.onTrack, next);
      expect(n, 1);
    });

    test('setOffTrack and setThumb mutate the right fields', () {
      final s = SwitchState();
      const a = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFAAAAAA),
      );
      const b = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFFBBBBBB),
      );
      s.setOffTrack(a);
      s.setThumb(b);
      expect(s.offTrack, a);
      expect(s.thumb, b);
    });

    test('setDisabled toggles between null and a style', () {
      final s = SwitchState();
      const dim = PixelShapeStyle(
        corners: PixelCorners.sm,
        fillColor: Color(0xFF333333),
      );
      s.setDisabled(dim);
      expect(s.disabledStyle, dim);
      s.setDisabled(null);
      expect(s.disabledStyle, isNull);
    });

    test('togglePreviewValue flips the bool and notifies', () {
      final s = SwitchState();
      var n = 0;
      s.addListener(() => n++);
      s.togglePreviewValue();
      expect(s.previewValue, isTrue);
      s.togglePreviewValue();
      expect(s.previewValue, isFalse);
      expect(n, 2);
    });
  });
}
