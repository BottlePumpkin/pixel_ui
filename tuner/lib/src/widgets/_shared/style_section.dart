import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../controls/border_width_slider.dart';
import '../../controls/color_hex_input.dart';
import '../../controls/corner_picker.dart';
import '../../controls/shadow_editor.dart';
import '../../controls/texture_editor.dart';
import '../pixel_card.dart';
import '../pixel_section_header.dart';

/// All 5 sub-controls for a single [PixelShapeStyle], grouped in a [PixelCard]
/// with an optional collapsible header.
class StyleSection extends StatefulWidget {
  final String title;
  final PixelShapeStyle value;
  final ValueChanged<PixelShapeStyle> onChanged;
  final bool collapsedByDefault;

  const StyleSection({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.collapsedByDefault = false,
  });

  @override
  State<StyleSection> createState() => _StyleSectionState();
}

class _StyleSectionState extends State<StyleSection> {
  late bool _expanded = !widget.collapsedByDefault;

  @override
  Widget build(BuildContext context) {
    final s = widget.value;
    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(child: PixelSectionHeader(widget.title)),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (_expanded) ...[
            CornerPicker(
              value: s.corners,
              onChanged: (c) => widget.onChanged(s.copyWith(corners: c)),
            ),
            const SizedBox(height: 8),
            ColorHexInput(
              label: 'fill',
              value: s.fillColor,
              onChanged: (c) {
                if (c != null) {
                  widget.onChanged(s.copyWith(fillColor: c));
                }
              },
            ),
            const SizedBox(height: 8),
            ColorHexInput(
              label: 'border',
              value: s.borderColor,
              nullable: true,
              onChanged: (c) =>
                  widget.onChanged(s.copyWith(borderColor: c)),
            ),
            const SizedBox(height: 8),
            BorderWidthSlider(
              borderWidth: s.borderWidth,
              hasBorderColor: s.borderColor != null,
              onChanged: (w) => widget.onChanged(s.copyWith(borderWidth: w)),
            ),
            const SizedBox(height: 8),
            ShadowEditor(
              value: s.shadow,
              onChanged: (sh) => widget.onChanged(s.copyWith(shadow: sh)),
            ),
            const SizedBox(height: 8),
            TextureEditor(
              value: s.texture,
              onChanged: (t) => widget.onChanged(s.copyWith(texture: t)),
            ),
          ],
        ],
      ),
    );
  }
}

/// A [StyleSection] wrapped in an on/off toggle. When off, [onChanged]
/// receives `null` and the section body is hidden.
class NullableStyleSection extends StatelessWidget {
  final String title;
  final PixelShapeStyle? value;
  final PixelShapeStyle defaultWhenEnabling;
  final ValueChanged<PixelShapeStyle?> onChanged;

  const NullableStyleSection({
    super.key,
    required this.title,
    required this.value,
    required this.defaultWhenEnabling,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = value != null;
    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: PixelSectionHeader(title)),
              Switch(
                value: enabled,
                onChanged: (on) {
                  onChanged(on ? defaultWhenEnabling : null);
                },
              ),
            ],
          ),
          if (enabled)
            StyleSection(
              title: '$title — fields',
              value: value!,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}
