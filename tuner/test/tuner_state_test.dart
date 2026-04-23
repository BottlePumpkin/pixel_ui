import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/tuner_state.dart';

void main() {
  group('TunerState', () {
    test('initial state uses lg corners, green fill, thin border, sm shadow', () {
      final state = TunerState();
      expect(state.value.corners, PixelCorners.lg);
      expect(state.value.fillColor, const Color(0xFF5A8A3A));
      expect(state.value.borderColor, const Color(0xFF2A4820));
      expect(state.value.borderWidth, 1);
      expect(state.value.shadow?.offset, const Offset(1, 1));
      expect(state.value.texture, isNull);
    });

    test('setCorners updates corners and notifies listeners', () {
      final state = TunerState();
      var notified = 0;
      state.addListener(() => notified++);
      state.setCorners(PixelCorners.sharp);
      expect(state.value.corners, PixelCorners.sharp);
      expect(notified, 1);
    });

    test('setBorderColor(null) clears border color', () {
      final state = TunerState();
      state.setBorderColor(null);
      expect(state.value.borderColor, isNull);
    });

    test('setShadow(null) clears shadow', () {
      final state = TunerState();
      state.setShadow(null);
      expect(state.value.shadow, isNull);
    });
  });
}
