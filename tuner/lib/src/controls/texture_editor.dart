import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'color_hex_input.dart';

class TextureEditor extends StatefulWidget {
  final PixelTexture? value;
  final ValueChanged<PixelTexture?> onChanged;

  const TextureEditor({super.key, required this.value, required this.onChanged});

  @override
  State<TextureEditor> createState() => _TextureEditorState();
}

class _TextureEditorState extends State<TextureEditor> {
  final _rng = math.Random();

  static const _defaultColor = Color(0xFF000000);

  PixelTexture _default() =>
      const PixelTexture(density: 0.3, size: 1, seed: 0, color: _defaultColor);

  @override
  Widget build(BuildContext context) {
    final t = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: t != null,
              onChanged: (on) {
                widget.onChanged(on == true ? _default() : null);
              },
            ),
            const Text('texture'),
          ],
        ),
        if (t != null) ...[
          _DoubleSlider(
            label: 'density',
            value: t.density,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (v) => widget.onChanged(
              PixelTexture(density: v, size: t.size, seed: t.seed, color: t.color),
            ),
          ),
          _IntSlider(
            label: 'size',
            value: t.size,
            min: 1,
            max: 4,
            onChanged: (v) => widget.onChanged(
              PixelTexture(density: t.density, size: v, seed: t.seed, color: t.color),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _IntSlider(
                  label: 'seed',
                  value: t.seed,
                  min: 0,
                  max: 100,
                  onChanged: (v) => widget.onChanged(
                    PixelTexture(density: t.density, size: t.size, seed: v, color: t.color),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.casino),
                tooltip: 'random seed',
                onPressed: () => widget.onChanged(
                  PixelTexture(
                    density: t.density,
                    size: t.size,
                    seed: _rng.nextInt(101),
                    color: t.color,
                  ),
                ),
              ),
            ],
          ),
          ColorHexInput(
            label: 'texture color',
            value: t.color,
            onChanged: (c) {
              if (c == null) return;
              widget.onChanged(
                PixelTexture(density: t.density, size: t.size, seed: t.seed, color: c),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _DoubleSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _DoubleSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(2), textAlign: TextAlign.end)),
      ],
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
        SizedBox(width: 60, child: Text(label)),
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
