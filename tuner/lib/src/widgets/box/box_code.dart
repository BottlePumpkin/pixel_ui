import 'package:pixel_ui/pixel_ui.dart';

import '../_shared/style_codegen.dart';

/// Generates a Dart source snippet declaring a `const style = PixelShapeStyle(...)`
/// equivalent to the given [style]. Nullable fields are omitted when null.
///
/// When [labelText] is non-null, appends a commented-out `PixelBox(label: ...)`
/// usage snippet so users can copy both pieces together.
String generateBoxCode(PixelShapeStyle style, {String? labelText}) {
  final lines = emitStyleConst(style, 'style');
  if (labelText != null && labelText.isNotEmpty) {
    lines.add('');
    lines.add('// Paired usage:');
    lines.add('// PixelBox(');
    lines.add('//   logicalWidth: 32,');
    lines.add('//   logicalHeight: 16,');
    lines.add('//   style: style,');
    final escaped = labelText.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    lines.add("//   label: Text('$escaped'),");
    lines.add('// )');
  }
  return lines.join('\n');
}
