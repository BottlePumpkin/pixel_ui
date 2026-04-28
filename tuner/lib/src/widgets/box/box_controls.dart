import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../controls/border_width_slider.dart';
import '../../controls/color_hex_input.dart';
import '../../controls/corner_picker.dart';
import '../../controls/label_editor.dart';
import '../../controls/shadow_editor.dart';
import '../../controls/texture_editor.dart';
import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_section_header.dart';
import 'box_state.dart';

/// All Box controls (corners / colors / shadow / texture / label),
/// extracted verbatim from the old `_ControlsPanel` in `home_page.dart`.
class BoxControls extends StatelessWidget {
  final BoxState state;
  const BoxControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PixelShapeStyle>(
      valueListenable: state,
      builder: (context, style, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PixelSectionHeader('CORNERS'),
                  CornerPicker(
                    value: style.corners,
                    onChanged: state.setCorners,
                  ),
                ],
              ),
            ),
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PixelSectionHeader('COLORS'),
                  ColorHexInput(
                    label: 'fill',
                    value: style.fillColor,
                    onChanged: (c) {
                      if (c != null) state.setFillColor(c);
                    },
                  ),
                  const SizedBox(height: 8),
                  ColorHexInput(
                    label: 'border',
                    value: style.borderColor,
                    nullable: true,
                    onChanged: state.setBorderColor,
                  ),
                  const SizedBox(height: 8),
                  BorderWidthSlider(
                    borderWidth: style.borderWidth,
                    hasBorderColor: style.borderColor != null,
                    onChanged: state.setBorderWidth,
                  ),
                ],
              ),
            ),
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PixelSectionHeader('SHADOW'),
                  ShadowEditor(
                    value: style.shadow,
                    onChanged: state.setShadow,
                  ),
                ],
              ),
            ),
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PixelSectionHeader('TEXTURE'),
                  TextureEditor(
                    value: style.texture,
                    onChanged: state.setTexture,
                  ),
                ],
              ),
            ),
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PixelSectionHeader('LABEL'),
                  ValueListenableBuilder<String?>(
                    valueListenable: state.labelText,
                    builder: (context, labelText, _) {
                      return LabelEditor(
                        value: labelText,
                        onChanged: state.setLabel,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
