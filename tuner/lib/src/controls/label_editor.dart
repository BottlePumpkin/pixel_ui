import 'package:flutter/material.dart';

/// Text input + checkbox that edits the optional `PixelBox.label` for the
/// tuner preview.
class LabelEditor extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const LabelEditor({super.key, required this.value, required this.onChanged});

  @override
  State<LabelEditor> createState() => _LabelEditorState();
}

class _LabelEditorState extends State<LabelEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant LabelEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value ?? '';
    if (_controller.text != next) _controller.text = next;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: enabled,
              onChanged: (on) {
                if (on == true) {
                  widget.onChanged('LABEL');
                } else {
                  widget.onChanged(null);
                }
              },
            ),
            const Text('label'),
          ],
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.only(left: 36, right: 8),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => widget.onChanged(v),
            ),
          ),
      ],
    );
  }
}
