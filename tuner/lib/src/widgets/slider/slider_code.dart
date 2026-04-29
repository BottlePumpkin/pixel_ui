import '../_shared/style_codegen.dart';
import 'slider_state.dart';

/// Generates `const track/fill/thumb` (plus optional `disabled`) followed by
/// a `PixelSlider(...)` call. Omits `divisions:` when null.
String generateSliderCode(SliderState state) {
  final lines = <String>[];
  lines.addAll(emitStyleConst(state.track, 'track'));
  lines.add('');
  lines.addAll(emitStyleConst(state.fill, 'fill'));
  lines.add('');
  lines.addAll(emitStyleConst(state.thumb, 'thumb'));
  if (state.disabledStyle != null) {
    lines.add('');
    lines.addAll(emitStyleConst(state.disabledStyle!, 'disabled'));
  }
  lines.add('');
  lines.add('PixelSlider(');
  lines.add('  value: ${state.previewValue},');
  lines.add('  onChanged: (v) {},');
  lines.add('  min: ${state.min},');
  lines.add('  max: ${state.max},');
  if (state.divisions != null) {
    lines.add('  divisions: ${state.divisions},');
  }
  lines.add('  trackStyle: track,');
  lines.add('  fillStyle: fill,');
  lines.add('  thumbStyle: thumb,');
  if (state.disabledStyle != null) {
    lines.add('  disabledStyle: disabled,');
  }
  lines.add(');');
  return lines.join('\n');
}
