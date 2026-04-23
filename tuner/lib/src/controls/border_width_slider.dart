import 'package:flutter/material.dart';

/// 0–4 int border width slider; disables when [hasBorderColor] is false.
class BorderWidthSlider extends StatelessWidget {
  final int value;
  final bool hasBorderColor;
  final ValueChanged<int> onChanged;

  const BorderWidthSlider({
    super.key,
    required this.value,
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
            value: value.toDouble(),
            min: 0,
            max: 4,
            divisions: 4,
            label: '$value',
            onChanged: hasBorderColor ? (v) => onChanged(v.round()) : null,
          ),
        ),
        SizedBox(width: 24, child: Text('$value')),
      ],
    );
  }
}
