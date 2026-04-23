import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Picker for corner presets sharp/xs/sm/md/lg/xl, plus a "custom" mode
/// with a single depth slider (0..6) applied symmetrically to all corners.
class CornerPicker extends StatefulWidget {
  final PixelCorners value;
  final ValueChanged<PixelCorners> onChanged;

  const CornerPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CornerPicker> createState() => _CornerPickerState();
}

class _CornerPickerState extends State<CornerPicker> {
  static const _presets = <String, PixelCorners>{
    'sharp': PixelCorners.sharp,
    'xs': PixelCorners.xs,
    'sm': PixelCorners.sm,
    'md': PixelCorners.md,
    'lg': PixelCorners.lg,
    'xl': PixelCorners.xl,
  };

  String _selected = 'lg';
  int _customDepth = 3;

  @override
  void initState() {
    super.initState();
    _syncFromValue();
  }

  @override
  void didUpdateWidget(covariant CornerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _syncFromValue();
  }

  void _syncFromValue() {
    for (final entry in _presets.entries) {
      if (identical(widget.value, entry.value) || widget.value == entry.value) {
        _selected = entry.key;
        return;
      }
    }
    _selected = 'custom';
  }

  PixelCorners _customCorners(int depth) {
    if (depth <= 0) return PixelCorners.sharp;
    final pattern = List.generate(depth, (i) => depth - i);
    return PixelCorners.all(pattern);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ..._presets.entries.map(
              (e) => _PresetButton(
                label: e.key,
                selected: _selected == e.key,
                onTap: () {
                  setState(() => _selected = e.key);
                  widget.onChanged(e.value);
                },
              ),
            ),
            _PresetButton(
              label: 'custom',
              selected: _selected == 'custom',
              onTap: () {
                setState(() => _selected = 'custom');
                widget.onChanged(_customCorners(_customDepth));
              },
            ),
          ],
        ),
        if (_selected == 'custom') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('depth'),
              Expanded(
                child: Slider(
                  value: _customDepth.toDouble(),
                  min: 0,
                  max: 6,
                  divisions: 6,
                  label: '$_customDepth',
                  onChanged: (v) {
                    setState(() => _customDepth = v.round());
                    widget.onChanged(_customCorners(_customDepth));
                  },
                ),
              ),
              SizedBox(width: 24, child: Text('$_customDepth')),
            ],
          ),
        ],
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5A8A3A) : const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF2A2A2A),
          ),
        ),
      ),
    );
  }
}
