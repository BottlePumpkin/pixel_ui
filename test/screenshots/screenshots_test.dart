// test/screenshots/screenshots_test.dart
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_ui/pixel_ui.dart';

import 'scenes/_frame.dart';
import 'scenes/buttons_scene.dart';
import 'scenes/corners_scene.dart';
import 'scenes/hero_scene.dart';
import 'scenes/shadows_scene.dart';
import 'scenes/texture_scene.dart';

Future<void> _loadMulmaru() async {
  final bytes = await rootBundle.load('assets/fonts/Mulmaru.ttf');
  // TextStyle(package: 'pixel_ui') resolves the font family key to
  // 'packages/pixel_ui/Mulmaru' inside the engine. FontLoader must use
  // that same key so the test renderer picks up the real font rather than
  // falling back to Ahem.
  final loader =
      FontLoader('packages/${PixelText.mulmaruPackage}/${PixelText.mulmaruFontFamily}')
        ..addFont(Future.value(bytes));
  await loader.load();
}

Future<void> _pumpScene(WidgetTester tester, Widget scene) async {
  tester.view.physicalSize = const Size(2560, 1440);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1280, 720)),
        child: scene,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadMulmaru);

  testWidgets('Mulmaru font loads (sanity)', (tester) async {
    await _pumpScene(
      tester,
      Center(
        child: Text(
          'ABC',
          style: PixelText.mulmaru(fontSize: 32),
        ),
      ),
    );
    final renderParagraph =
        tester.renderObject(find.text('ABC')) as RenderParagraph;
    final width = renderParagraph.size.width;
    // Ahem renders each glyph as an em-wide square, so 3×32 = 96 exactly.
    // Mulmaru's proportional metrics produce a different width.
    expect(width, isNot(equals(96.0)),
        reason: 'Expected Mulmaru width, got Ahem fallback ($width)');
  });

  final scenes = <(String, Widget)>[
    ('01_hero', const HeroScene()),
    ('02_corners', const CornersScene()),
    ('03_shadows', const ShadowsScene()),
    ('04_buttons', const ButtonsScene()),
    ('05_texture', const TextureScene()),
  ];

  for (final (name, scene) in scenes) {
    testWidgets('screenshot: $name', (tester) async {
      await _pumpScene(tester, scene);
      await expectLater(
        find.byType(ScreenshotFrame),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}

// Silence unused-import warning for the ui library — kept for future tweaks
// like using `ui.PlatformDispatcher` if needed.
// ignore: unused_element
void _touchUiLibrary() {
  ui.PlatformDispatcher.instance;
}
