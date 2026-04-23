import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'color_hex_input.dart';

class ShadowEditor extends StatelessWidget {
  final PixelShadow? value;
  final ValueChanged<PixelShadow?> onChanged;

  const ShadowEditor({super.key, required this.value, required this.onChanged});

  static const _defaultColor = Color(0xFF1A3010);

  @override
  Widget build(BuildContext context) {
    final enabled = value != null;
    final dx = value?.offset.dx.toInt() ?? 1;
    final dy = value?.offset.dy.toInt() ?? 1;
    final color = value?.color ?? _defaultColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: enabled,
              onChanged: (on) {
                if (on == true) {
                  onChanged(
                    const PixelShadow(
                      offset: Offset(1, 1),
                      color: _defaultColor,
                    ),
                  );
                } else {
                  onChanged(null);
                }
              },
            ),
            const Text('shadow'),
            const SizedBox(width: 16),
            _PresetButton(
              label: 'sm',
              onTap: enabled
                  ? () => onChanged(PixelShadow(offset: const Offset(1, 1), color: color))
                  : null,
            ),
            _PresetButton(
              label: 'md',
              onTap: enabled
                  ? () => onChanged(PixelShadow(offset: const Offset(2, 2), color: color))
                  : null,
            ),
            _PresetButton(
              label: 'lg',
              onTap: enabled
                  ? () => onChanged(PixelShadow(offset: const Offset(4, 4), color: color))
                  : null,
            ),
          ],
        ),
        if (enabled) ...[
          _IntSlider(
            label: 'dx',
            value: dx,
            min: -3,
            max: 3,
            onChanged: (v) => onChanged(
              PixelShadow(offset: Offset(v.toDouble(), dy.toDouble()), color: color),
            ),
          ),
          _IntSlider(
            label: 'dy',
            value: dy,
            min: -3,
            max: 3,
            onChanged: (v) => onChanged(
              PixelShadow(offset: Offset(dx.toDouble(), v.toDouble()), color: color),
            ),
          ),
          ColorHexInput(
            label: 'shadow color',
            value: color,
            onChanged: (c) {
              if (c == null) return;
              onChanged(PixelShadow(offset: Offset(dx.toDouble(), dy.toDouble()), color: c));
            },
          ),
        ],
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: onTap == null ? const Color(0xFFDDDDDD) : const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _IntSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _IntSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.end)),
      ],
    );
  }
}
