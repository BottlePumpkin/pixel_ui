# pixel_ui

[![pub package](https://img.shields.io/pub/v/pixel_ui.svg)](https://pub.dev/packages/pixel_ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Test](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/test.yml)
[![Platform Build](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml/badge.svg)](https://github.com/BottlePumpkin/pixel_ui/actions/workflows/build.yml)
[![Live Tuner](https://img.shields.io/badge/Live-Tuner-5A8A3A.svg)](https://bottlepumpkin.github.io/pixel_ui/)

Pixel-art design system for Flutter — parametric shapes, interactive buttons, and a bundled pixel font.

**🎨 [Try the PixelShapeStyle tuner →](https://bottlepumpkin.github.io/pixel_ui/)**

![pixel_ui hero — logo, corners, shadow, and texture primitives](doc/screenshots/01_hero.png)

## Features

- Stair-pattern asymmetric corners (`PixelCorners` with `.sharp`/`.xs`/`.sm`/`.md`/`.lg`/`.xl` presets, plus fully custom per-corner control)
- Deterministic LCG texture overlays
- Pixel-aware drop shadows with `.sm`/`.md`/`.lg` factories
- Press-state–aware interactive pixel buttons (`PixelButton`)
- Bundled Mulmaru pixel font (SIL OFL 1.1) with a ready-made `TextStyle` factory
- Zero external dependencies beyond the Flutter SDK

## Platforms

| Platform | Status | Verification |
|----------|--------|--------------|
| Android  | ✅      | CI build (debug APK) |
| iOS      | ✅      | CI build (no-codesign) |
| Web      | ✅      | CI build + smoke-tested on Chrome |
| macOS    | ✅      | CI build + smoke-tested locally |
| Linux    | ✅      | CI build |
| Windows  | ✅      | CI build |

> Web is smoke-tested on Chrome. Other browsers (Safari, Firefox)
> should work but are not part of release validation. Linux and Windows
> are validated by CI build only — please file an issue if you find
> rendering glitches on those platforms.

## Install

```yaml
dependencies:
  pixel_ui: ^0.1.0
```

## Quick Start

```dart
import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

final style = PixelShapeStyle(
  corners: PixelCorners.lg,
  fillColor: const Color(0xFF5A8A3A),
  borderColor: const Color(0xFF2A4820),
  borderWidth: 1,
  shadow: PixelShadow.sm(const Color(0xFF1A3010)),
);

PixelButton(
  logicalWidth: 60,
  logicalHeight: 18,
  normalStyle: style,
  onPressed: () {},
  child: Text(
    'START',
    style: PixelText.mulmaru(fontSize: 18, color: const Color(0xFFFFFFFF)),
  ),
);
```

## Usage

### Corners

`PixelCorners` describes an asymmetric per-corner stair pattern. Use the provided scale constants or compose your own:

```dart
const PixelCorners.all([3, 2, 1])                     // symmetric medium
const PixelCorners.only(tl: [3, 2, 1], tr: [3, 2, 1]) // top tab

PixelCorners.sharp   // all square
PixelCorners.xs      // 1-pixel rounding
PixelCorners.md      // 3-row stair
PixelCorners.lg      // 4-row stair
```

### Shadows

```dart
PixelShadow.sm(Colors.black)                                 // offset (1, 1)
PixelShadow.md(Colors.black)                                 // offset (2, 2)
PixelShadow.lg(Colors.black)                                 // offset (4, 4)
const PixelShadow(offset: Offset(3, 2), color: Colors.black) // custom
```

### PixelButton

```dart
PixelButton(
  logicalWidth: 60,
  logicalHeight: 18,
  normalStyle: /* PixelShapeStyle */,
  pressedStyle: /* optional, falls back to normalStyle */,
  pressChildOffset: const Offset(0, 1),
  onPressed: () {},
  semanticsLabel: 'Start',
  child: /* your child widget */,
);
```

### Texture

```dart
PixelShapeStyle(
  corners: PixelCorners.md,
  fillColor: const Color(0xFFFFD643),
  texture: const PixelTexture(
    color: Color(0xFFFFF7D0),
    density: 0.15,
    size: 1,
    seed: 7,
  ),
);
```

Textures use a deterministic LCG so identical settings produce identical patterns across platforms and builds.

### Typography

The package bundles the Mulmaru proportional pixel font. Use the factory helper:

```dart
Text('달려라', style: PixelText.mulmaru(fontSize: 20, color: Colors.white));
```

Or compose a custom `TextStyle` using the exposed constants:

```dart
Text(
  'hello',
  style: TextStyle(
    fontFamily: PixelText.mulmaruFontFamily,
    package: PixelText.mulmaruPackage,
    fontSize: 18,
  ),
);
```

#### Monospaced variant

For code, terminal-style UI, or fixed-width layouts, use `PixelText.mulmaruMono`:

```dart
Text(
  'HP 042/100',
  style: PixelText.mulmaruMono(fontSize: 12, color: Colors.white),
)
```

## Gallery

| Corners | Shadows |
| --- | --- |
| ![Corner stair presets: sharp, xs, sm, md, lg, xl, and an asymmetric tab](doc/screenshots/02_corners.png) | ![Pixel drop shadows at sm, md, lg offsets](doc/screenshots/03_shadows.png) |

| Buttons | Texture |
| --- | --- |
| ![PixelButton states: normal, pressed, disabled](doc/screenshots/04_buttons.png) | ![Deterministic LCG texture overlay — plain vs textured](doc/screenshots/05_texture.png) |

## Example

See `example/lib/main.dart` for a full showcase of every primitive. Run:

```bash
cd example
flutter run
```

## Bundled Font

This package bundles the [Mulmaru](https://github.com/mushsooni/mulmaru) pixel fonts (proportional + monospaced variants) by **mushsooni**, distributed under the SIL Open Font License 1.1.

See [OFL.txt](OFL.txt) for the full font license. Apps using `pixel_ui` should include OFL attribution in their open-source license disclosures; Flutter's `showLicensePage()` handles this automatically when the bundling note (see [LICENSE](LICENSE)) is in place.

## Contributing

Issues and PRs are welcome at [github.com/BottlePumpkin/pixel_ui/issues](https://github.com/BottlePumpkin/pixel_ui/issues).

## License

MIT for code (see [LICENSE](LICENSE)). Bundled Mulmaru font is under SIL OFL 1.1 (see [OFL.txt](OFL.txt)).
