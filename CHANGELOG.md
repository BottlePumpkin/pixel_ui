# Changelog

## 0.2.0 — 2026-04-23

### Added
- Official platform support: Web, macOS, Linux, Windows (in addition to existing iOS, Android).
- `.github/workflows/build.yml` CI workflow that builds the example app on 6 OS/target combinations.
- README "Platforms" section documenting verification level for each platform.

### Changed
- example app showcase is now constrained to 480px max width on wide viewports (desktop, web), keeping the mobile-style layout centered. Mobile rendering is unaffected.

## 0.1.2 — 2026-04-22

### Added
- README hero image and gallery section embedding the 5 pub.dev screenshots.

## 0.1.1 — 2026-04-22

### Added
- pub.dev screenshots (5) generated via golden tests from `test/screenshots/scenes/`.
- `tool/update_screenshots.sh` regenerates goldens and syncs them to `doc/screenshots/`.

## 0.1.0 — 2026-04-22

Initial public release.

### Features
- `PixelCorners`: asymmetric per-corner stair pattern with `.sharp`/`.xs`/`.sm`/`.md`/`.lg`/`.xl` static presets.
- `PixelShadow`: pixel drop shadow with `.sm`/`.md`/`.lg` factory constructors (offsets 1/2/4).
- `PixelTexture`: deterministic LCG noise overlay.
- `PixelShapeStyle`: composable shape style with sentinel-based `copyWith` (`null` clears, omit preserves).
- `PixelShapePainter`: low-level `CustomPainter` for pixel rendering.
- `PixelBox`: container widget with automatic size resolution by logical ratio.
- `PixelButton`: interactive pixel button with normal/pressed styles, press-down animation, and `Semantics` integration.
- `PixelText`: static namespace exposing `mulmaruFontFamily`/`mulmaruPackage` constants and a `mulmaru()` TextStyle factory.
- Bundled Mulmaru Proportional pixel font (SIL OFL 1.1).

### Bundled font integrity
- `assets/fonts/Mulmaru.ttf` SHA-256: `02545e10374c0797be32df8670e18663c6ab73eea6966bb98f4ffd0283138810`
- Size: 1,606,948 bytes
- Source: https://github.com/mushsooni/mulmaru
