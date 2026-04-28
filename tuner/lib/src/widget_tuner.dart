import 'package:flutter/widgets.dart';

/// A tunable pixel_ui widget module used by the tuner home page.
///
/// Each implementation owns its own state and exposes three build methods
/// for the three panels (controls / preview / code) plus a sidebar
/// identity ([name] + [pixelIcon]). [dispose] cleans up the state object
/// when the tuner is unloaded.
abstract class WidgetTuner {
  /// Display name for the sidebar and header. e.g. `'PixelBox'`.
  String get name;

  /// 16×16 logical pixel icon used in NavigationRail destinations and
  /// Drawer rows. Implementations typically compose a small `PixelBox`.
  Widget get pixelIcon;

  /// Controls panel — corners / colors / shadow / texture editors etc.
  /// Wide layout: middle column. Narrow layout: bottom of the stack.
  Widget buildControls(BuildContext context);

  /// Live preview — renders the current widget state on a checkerboard
  /// background. Wide layout: top-right. Narrow layout: top.
  Widget buildPreview(BuildContext context);

  /// Read-only Dart source view + COPY CODE button. Wide layout:
  /// bottom-right. Narrow layout: middle.
  Widget buildCode(BuildContext context);

  /// Releases internal state objects (ValueNotifier / ChangeNotifier).
  /// Called from `HomePage.dispose`.
  void dispose();
}
