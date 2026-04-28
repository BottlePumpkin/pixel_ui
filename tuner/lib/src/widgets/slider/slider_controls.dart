import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_section_header.dart';
import '../_shared/style_section.dart';
import 'slider_state.dart';

class SliderControls extends StatelessWidget {
  final SliderState state;
  const SliderControls({super.key, required this.state});

  static const _disabledDefault = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF333333),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StyleSection(
              title: 'TRACK',
              value: state.track,
              onChanged: state.setTrack,
            ),
            StyleSection(
              title: 'FILL',
              value: state.fill,
              onChanged: state.setFill,
              collapsedByDefault: true,
            ),
            StyleSection(
              title: 'THUMB',
              value: state.thumb,
              onChanged: state.setThumb,
              collapsedByDefault: true,
            ),
            NullableStyleSection(
              title: 'DISABLED',
              value: state.disabledStyle,
              defaultWhenEnabling: _disabledDefault,
              onChanged: state.setDisabled,
            ),
            _RangeSection(state: state),
            _PreviewValueSection(state: state),
          ],
        );
      },
    );
  }
}

class _RangeSection extends StatefulWidget {
  final SliderState state;
  const _RangeSection({required this.state});

  @override
  State<_RangeSection> createState() => _RangeSectionState();
}

class _RangeSectionState extends State<_RangeSection> {
  late final TextEditingController _minCtrl =
      TextEditingController(text: widget.state.min.toString());
  late final TextEditingController _maxCtrl =
      TextEditingController(text: widget.state.max.toString());
  late final TextEditingController _divCtrl =
      TextEditingController(text: widget.state.divisions?.toString() ?? '');

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _divCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PixelSectionHeader('RANGE'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  decoration: const InputDecoration(labelText: 'min'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onSubmitted: (s) {
                    final v = double.tryParse(s);
                    if (v != null) widget.state.setMin(v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  decoration: const InputDecoration(labelText: 'max'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onSubmitted: (s) {
                    final v = double.tryParse(s);
                    if (v != null) widget.state.setMax(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _divCtrl,
                  decoration: const InputDecoration(
                    labelText: 'divisions (blank = continuous)',
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (s) {
                    if (s.isEmpty) {
                      widget.state.setDivisions(null);
                    } else {
                      final v = int.tryParse(s);
                      if (v != null) widget.state.setDivisions(v);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewValueSection extends StatelessWidget {
  final SliderState state;
  const _PreviewValueSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PixelSectionHeader('PREVIEW VALUE'),
          Slider(
            min: state.min,
            max: state.max,
            divisions: state.divisions,
            value: state.previewValue,
            onChanged: state.setPreviewValue,
          ),
          Text('value: ${state.previewValue.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
