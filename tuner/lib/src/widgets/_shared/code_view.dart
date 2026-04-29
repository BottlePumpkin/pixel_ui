import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Dark-themed read-only code view + COPY CODE button.
///
/// Accepts the rendered Dart source as a [code] prop; widget-specific
/// generation lives in each `WidgetTuner.buildCode` callsite.
class CodeView extends StatelessWidget {
  final String code;
  const CodeView({super.key, required this.code});

  static const _bgColor = Color(0xFF1A1A1A);
  static const _textColor = Color(0xFF9CCC65);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
          ),
          child: SelectableText(
            code,
            style: PixelText.mulmaruMono(
              fontSize: 12,
              color: _textColor,
              height: 1.4,
            ),
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
