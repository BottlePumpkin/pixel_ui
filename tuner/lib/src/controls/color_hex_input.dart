import 'package:flutter/material.dart';

import '../color_hex_parser.dart';

/// Inline color editor: optional enabled checkbox → swatch → hex TextField.
///
/// - If [nullable] is true, a leading checkbox toggles the color on/off and
///   calls `onChanged(null)` when unchecked.
/// - Hex validation happens in real time; invalid input keeps the last
///   committed value and marks the field errored.
class ColorHexInput extends StatefulWidget {
  final String label;
  final Color? value;
  final ValueChanged<Color?> onChanged;
  final bool nullable;

  const ColorHexInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.nullable = false,
  });

  @override
  State<ColorHexInput> createState() => _ColorHexInputState();
}

class _ColorHexInputState extends State<ColorHexInput> {
  late final TextEditingController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _hexOf(widget.value));
  }

  @override
  void didUpdateWidget(covariant ColorHexInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _hexOf(widget.value);
    }
  }

  String _hexOf(Color? c) {
    if (c == null) return '';
    // Flutter 3.32+ exposes toARGB32(); Color.value is deprecated.
    final v = c.toARGB32();
    return v.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.value != null || !widget.nullable;
    return Row(
      children: [
        if (widget.nullable)
          Checkbox(
            value: widget.value != null,
            onChanged: (on) {
              if (on == true) {
                widget.onChanged(const Color(0xFF000000));
              } else {
                widget.onChanged(null);
              }
            },
          ),
        SizedBox(
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: widget.value ?? const Color(0xFFFFFFFF),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixText: '#',
              errorText: _hasError ? 'invalid hex' : null,
            ),
            onChanged: (text) {
              final parsed = parseHex(text);
              if (parsed == null) {
                setState(() => _hasError = true);
                return;
              }
              setState(() => _hasError = false);
              widget.onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}
