import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() => runApp(const PixelUiShowcaseApp());

class PixelUiShowcaseApp extends StatelessWidget {
  const PixelUiShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pixel_ui showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F1E8),
        textTheme: Typography.blackMountainView.apply(
          fontFamily: PixelText.mulmaruFontFamily,
          package: PixelText.mulmaruPackage,
        ),
      ),
      home: const _ShowcaseScreen(),
    );
  }
}

class _ShowcaseScreen extends StatelessWidget {
  const _ShowcaseScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pixel_ui', style: PixelText.mulmaru(fontSize: 20)),
        backgroundColor: const Color(0xFFE8DFC6),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: const [
              _HeroComposition(),
              _SectionDivider('1. Corners scale'),
              _CornersShowcase(),
              _SectionDivider('2. Shadows'),
              _ShadowsShowcase(),
              _SectionDivider('3. Buttons'),
              _ButtonsShowcase(),
              _SectionDivider('4. Texture'),
              _TextureShowcase(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(title, style: PixelText.mulmaru(fontSize: 18)),
    );
  }
}

/// Section 1 — all corner scales side by side.
class _CornersShowcase extends StatelessWidget {
  const _CornersShowcase();

  @override
  Widget build(BuildContext context) {
    const items = <(String, PixelCorners)>[
      ('sharp', PixelCorners.sharp),
      ('xs', PixelCorners.xs),
      ('sm', PixelCorners.sm),
      ('md', PixelCorners.md),
      ('lg', PixelCorners.lg),
      ('xl', PixelCorners.xl),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final (label, corners) in items)
            _Labelled(
              label,
              PixelBox(
                logicalWidth: 16,
                logicalHeight: 16,
                style: PixelShapeStyle(
                  corners: corners,
                  fillColor: const Color(0xFF5A8A3A),
                  borderColor: const Color(0xFF2A4820),
                  borderWidth: 1,
                ),
              ),
            ),
          _Labelled(
            'topTab',
            PixelBox(
              logicalWidth: 32,
              logicalHeight: 16,
              style: const PixelShapeStyle(
                corners: PixelCorners.only(tl: [3, 2, 1], tr: [3, 2, 1]),
                fillColor: Color(0xFFE07A3C),
                borderColor: Color(0xFF8B3E1A),
                borderWidth: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 2 — sm/md/lg shadow scale.
class _ShadowsShowcase extends StatelessWidget {
  const _ShadowsShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _Labelled(
            'sm',
            PixelBox(
              logicalWidth: 16,
              logicalHeight: 16,
              style: PixelShapeStyle(
                corners: PixelCorners.md,
                fillColor: const Color(0xFFFFD643),
                shadow: PixelShadow.sm(const Color(0xFF8A5A10)),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _Labelled(
            'md',
            PixelBox(
              logicalWidth: 16,
              logicalHeight: 16,
              style: PixelShapeStyle(
                corners: PixelCorners.md,
                fillColor: const Color(0xFFFFD643),
                shadow: PixelShadow.md(const Color(0xFF8A5A10)),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _Labelled(
            'lg',
            PixelBox(
              logicalWidth: 16,
              logicalHeight: 16,
              style: PixelShapeStyle(
                corners: PixelCorners.md,
                fillColor: const Color(0xFFFFD643),
                shadow: PixelShadow.lg(const Color(0xFF8A5A10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 3 — interactive button states.
class _ButtonsShowcase extends StatefulWidget {
  const _ButtonsShowcase();

  @override
  State<_ButtonsShowcase> createState() => _ButtonsShowcaseState();
}

class _ButtonsShowcaseState extends State<_ButtonsShowcase> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    const baseNormal = PixelShapeStyle(
      corners: PixelCorners.lg,
      fillColor: Color(0xFF5A8A3A),
      borderColor: Color(0xFF2A4820),
      borderWidth: 1,
      shadow: PixelShadow(offset: Offset(1, 1), color: Color(0xFF1A3010)),
    );
    const basePressed = PixelShapeStyle(
      corners: PixelCorners.lg,
      fillColor: Color(0xFF3E6028),
      borderColor: Color(0xFF1A3010),
      borderWidth: 1,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pressed count: $_count', style: PixelText.mulmaru(fontSize: 14)),
          const SizedBox(height: 12),
          PixelButton(
            logicalWidth: 60,
            logicalHeight: 18,
            width: 240,
            normalStyle: baseNormal,
            pressedStyle: basePressed,
            pressChildOffset: const Offset(0, 1),
            onPressed: () => setState(() => _count++),
            semanticsLabel: 'Tap counter',
            child: Text(
              'TAP ME',
              style: PixelText.mulmaru(
                fontSize: 18,
                color: Colors.white,
                shadowColor: const Color(0xFF1A3010),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PixelButton(
            logicalWidth: 60,
            logicalHeight: 18,
            width: 240,
            normalStyle: baseNormal,
            onPressed: null,
            child: Text(
              'DISABLED',
              style: PixelText.mulmaru(
                fontSize: 18,
                color: Colors.white,
                shadowColor: const Color(0xFF1A3010),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 4 — texture vs plain.
class _TextureShowcase extends StatelessWidget {
  const _TextureShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _Labelled(
            'plain',
            PixelBox(
              logicalWidth: 20,
              logicalHeight: 20,
              style: const PixelShapeStyle(
                corners: PixelCorners.md,
                fillColor: Color(0xFFFFD643),
                borderColor: Color(0xFF8A5A10),
                borderWidth: 1,
              ),
            ),
          ),
          const SizedBox(width: 24),
          _Labelled(
            'textured',
            PixelBox(
              logicalWidth: 20,
              logicalHeight: 20,
              style: const PixelShapeStyle(
                corners: PixelCorners.md,
                fillColor: Color(0xFFFFD643),
                borderColor: Color(0xFF8A5A10),
                borderWidth: 1,
                texture: PixelTexture(
                  color: Color(0xFFFFF7D0),
                  density: 0.15,
                  size: 1,
                  seed: 7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 5 — hero composition for pub.dev screenshot #1.
class _HeroComposition extends StatelessWidget {
  const _HeroComposition();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PixelBox(
        logicalWidth: 100,
        logicalHeight: 60,
        width: MediaQuery.of(context).size.width - 48,
        style: const PixelShapeStyle(
          corners: PixelCorners.lg,
          fillColor: Color(0xFFE8DFC6),
          borderColor: Color(0xFF2A2A2A),
          borderWidth: 1,
          shadow: PixelShadow(offset: Offset(2, 2), color: Color(0xFF2A2A2A)),
          texture: PixelTexture(
            color: Color(0xFFFFFFFF),
            density: 0.08,
            size: 1,
            seed: 13,
          ),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PIXEL UI',
              style: PixelText.mulmaru(
                fontSize: 28,
                color: const Color(0xFF2A2A2A),
                shadowColor: const Color(0xFFE07A3C),
                shadowOffset: const Offset(2, 2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PRIMITIVES + FONT',
              style: PixelText.mulmaru(
                fontSize: 14,
                color: const Color(0xFF5A5A5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labelled(this.label, this.child);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(label, style: PixelText.mulmaru(fontSize: 12)),
      ],
    );
  }
}
