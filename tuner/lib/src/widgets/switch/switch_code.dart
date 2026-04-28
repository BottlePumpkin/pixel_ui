import '../_shared/style_codegen.dart';
import 'switch_state.dart';

/// Generates `const onTrack/offTrack/thumb` (plus optional `disabled`)
/// followed by a `PixelSwitch(...)` call using those consts.
String generateSwitchCode(SwitchState state) {
  final lines = <String>[];
  lines.addAll(emitStyleConst(state.onTrack, 'onTrack'));
  lines.add('');
  lines.addAll(emitStyleConst(state.offTrack, 'offTrack'));
  lines.add('');
  lines.addAll(emitStyleConst(state.thumb, 'thumb'));
  if (state.disabledStyle != null) {
    lines.add('');
    lines.addAll(emitStyleConst(state.disabledStyle!, 'disabled'));
  }
  lines.add('');
  lines.add('PixelSwitch(');
  lines.add('  value: ${state.previewValue},');
  lines.add('  onChanged: (v) {},');
  lines.add('  onTrackStyle: onTrack,');
  lines.add('  offTrackStyle: offTrack,');
  lines.add('  thumbStyle: thumb,');
  if (state.disabledStyle != null) {
    lines.add('  disabledStyle: disabled,');
  }
  lines.add(');');
  return lines.join('\n');
}
