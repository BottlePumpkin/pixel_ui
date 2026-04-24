import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import 'code_panel.dart';
import 'preview_panel.dart';
import 'tuner_state.dart';
import 'widgets/pixel_card.dart';
import 'widgets/pixel_section_header.dart';
import 'controls/border_width_slider.dart';
import 'controls/color_hex_input.dart';
import 'controls/corner_picker.dart';
import 'controls/label_editor.dart';
import 'controls/shadow_editor.dart';
import 'controls/texture_editor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _state = TunerState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          return SafeArea(
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: isWide
                      ? _WideLayout(state: _state)
                      : _StackedLayout(state: _state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF5A8A3A),
      child: Text(
        'PIXEL UI TUNER',
        style: PixelText.mulmaru(
          fontSize: 24,
          color: const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final TunerState state;
  const _WideLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 30,
          child: _ControlsPanel(state: state),
        ),
        Expanded(
          flex: 70,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PreviewPanel(state: state),
                CodePanel(state: state),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StackedLayout extends StatelessWidget {
  final TunerState state;
  const _StackedLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PreviewPanel(state: state),
          const SizedBox(height: 16),
          CodePanel(state: state),
          const SizedBox(height: 16),
          _ControlsPanel(state: state),
        ],
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  final TunerState state;
  const _ControlsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PixelShapeStyle>(
      valueListenable: state,
      builder: (context, style, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
          ),
        );
      },
    );
  }
}
