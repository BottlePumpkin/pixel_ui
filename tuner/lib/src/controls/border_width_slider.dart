import 'package:flutter/material.dart';

/// Slider for [PixelShapeStyle.borderWidth] (0–4, integer). Disables when
/// [hasBorderColor] is false. Declares the `borderWidth` identifier so the
/// coverage tool (`tool/check_tuner_coverage.dart`) can credit this control
/// for that field.
class BorderWidthSlider extends StatelessWidget {
  /// Current `borderWidth` in logical pixels.
  final int borderWidth;
  final bool hasBorderColor;
  final ValueChanged<int> onChanged;

  const BorderWidthSlider({
    super.key,
    required this.borderWidth,
    required this.hasBorderColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 60, child: Text('border')),
        Expanded(
          child: Slider(
            value: borderWidth.toDouble(),
            min: 0,
            max: 4,
            divisions: 4,
            label: '$borderWidth',
            onChanged: hasBorderColor ? (v) => onChanged(v.round()) : null,
          ),
        ),
        SizedBox(width: 24, child: Text('$borderWidth')),
      ],
    );
  }
}
