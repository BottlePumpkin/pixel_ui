import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'code_generator.dart';
import 'tuner_state.dart';
import 'widgets/pixel_section_header.dart';

/// Dark-themed code panel: PixelShapeStyle → Dart source + copy button.
///
/// Visual refinement R2: #1A1A1A background, #9CCC65 lime text, MulmaruMono font.
class CodePanel extends StatelessWidget {
  final TunerState state;
  const CodePanel({super.key, required this.state});

  static const _bgColor = Color(0xFF1A1A1A);
  static const _textColor = Color(0xFF9CCC65);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PixelSectionHeader('CODE'),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
          ),
          child: ValueListenableBuilder<PixelShapeStyle>(
            valueListenable: state,
            builder: (context, style, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: state.labelText,
                builder: (context, labelText, _) {
                  final code = generateCode(style, labelText: labelText);
                  return SelectableText(
                    code,
                    style: PixelText.mulmaruMono(
                      fontSize: 12,
                      color: _textColor,
                      height: 1.4,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: PixelButton(
            logicalWidth: 64,
            logicalHeight: 20,
            normalStyle: const PixelShapeStyle(
              corners: PixelCorners.sm,
              fillColor: Color(0xFF5A8A3A),
              borderColor: Color(0xFF2A4820),
              borderWidth: 1,
              shadow: PixelShadow(
                offset: Offset(1, 1),
                color: Color(0xFF1A3010),
              ),
            ),
            pressedStyle: const PixelShapeStyle(
              corners: PixelCorners.sm,
              fillColor: Color(0xFF4A7530),
              borderColor: Color(0xFF2A4820),
              borderWidth: 1,
            ),
            pressChildOffset: const Offset(0, 1),
            onPressed: () => _copy(context),
            child: Text(
              'COPY CODE',
              style: PixelText.mulmaru(
                fontSize: 12,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    final code = generateCode(state.value, labelText: state.labelText.value);
    try {
      await Clipboard.setData(ClipboardData(text: code));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied! Paste into your Dart source.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Copy unavailable — select the code and use Cmd+C / Ctrl+C.',
          ),
        ),
      );
    }
  }
}
