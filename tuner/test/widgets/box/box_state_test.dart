import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:pixel_ui_tuner/src/widgets/box/box_state.dart';

void main() {
  group('BoxState', () {
    test('initial state uses lg corners, green fill, thin border, sm shadow',
        () {
      final state = BoxState();
      expect(state.value.corners, PixelCorners.lg);
      expect(state.value.fillColor, const Color(0xFF5A8A3A));
      expect(state.value.borderColor, const Color(0xFF2A4820));
      expect(state.value.borderWidth, 1);
      expect(state.value.shadow?.offset, const Offset(1, 1));
      expect(state.value.texture, isNull);
    });

    test('setCorners updates corners and notifies listeners', () {
      final state = BoxState();
      var notified = 0;
      state.addListener(() => notified++);
      state.setCorners(PixelCorners.sharp);
      expect(state.value.corners, PixelCorners.sharp);
      expect(notified, 1);
    });

    test('setBorderColor(null) clears border color', () {
      final state = BoxState();
      state.setBorderColor(null);
      expect(state.value.borderColor, isNull);
    });

    test('setShadow(null) clears shadow', () {
      final state = BoxState();
      state.setShadow(null);
      expect(state.value.shadow, isNull);
    });

    test('setTexture stores texture object', () {
      final state = BoxState();
      const t = PixelTexture(
        color: Color(0xFFFFFFFF),
        density: 0.5,
        size: 1,
        seed: 1,
      );
      state.setTexture(t);
      expect(state.value.texture, t);
    });

    test('setLabel trims empty to null', () {
      final state = BoxState();
      state.setLabel('');
      expect(state.labelText.value, isNull);
      state.setLabel('INV');
      expect(state.labelText.value, 'INV');
    });
  });
}
