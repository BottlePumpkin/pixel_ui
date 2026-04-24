# Changelog

## 0.4.0 — 2026-04-24

### Fixed
- Texture cells no longer overflow the shape's bounding rect when `PixelTexture.size` exceeds the remaining logical space. Trailing cells are now clipped to fit. Previously a tile with `logicalWidth: 5, logicalHeight: 5` + `texture.size: 10` would bleed 50% into adjacent widgets (#34).

### Changed
- **Debug asserts on public painter/style/texture constructors.** Previously-silent misuse now fails loudly in debug builds (no effect in release). Closes #33 and #37.
  - `PixelShapePainter`: `logicalWidth > 0`, `logicalHeight > 0` on construction; `corners.topInsetRows + corners.bottomInsetRows <= logicalHeight` on first `paint()`. Prevents the silent corner-stair overlap that caused top/bottom loops to double-paint shared rows with mismatched insets (#33).
  - `PixelShapeStyle`: `borderWidth >= 0`.
  - `PixelTexture`: `size >= 1`, `0 <= density <= 1`.
- Callers hitting the new corner invariant should raise `logicalHeight` so the top+bottom stair fits — e.g. `PixelCorners.md` (3+3=6 rows) requires `logicalHeight >= 6`.

## 0.3.0 — 2026-04-24

### Added
- `PixelTheme` / `PixelBoxTheme` / `PixelButtonTheme` — `ThemeExtension`-based pixel defaults. Wire once with `pixelUiTheme(...)` on `MaterialApp.theme` and any descendant `PixelBox` / `PixelButton` inherits its style (#8).
- `pixelUiTheme({base, pixelTheme, boxTheme, buttonTheme})` factory returns a `ThemeData` with pixel extensions registered; explicit `boxTheme`/`buttonTheme` override slots on `pixelTheme`. Preserves unrelated extensions on `base`.
- `context.pixelTheme<T>()` shorthand for `Theme.of(context).extension<T>()`.
- `PixelShapePainterBuilder` typedef + `PixelBox.painter` optional prop + `PixelBoxTheme.painter` slot now active: inject a custom `CustomPainter` without forking `PixelBox` (#9). Precedence: `painter` prop > theme.painter > default `PixelShapePainter`.
- `PixelButton.disabledStyle` optional parameter — explicit `PixelShapeStyle` shown when `onPressed` is `null`. Unspecified keeps the existing behavior (`normalStyle` rendered at 50% opacity).

- `PixelShadowStyle { solid, stipple }` enum + `PixelShadow.style` field (default `.solid`, backward compatible). `stipple` renders the drop shadow as a 1-pixel checker pattern — retro "dithered" aesthetic alongside the existing solid look (#11). Tuner gains a `style` dropdown and emits `style: PixelShadowStyle.stipple` only when non-default.
- `PixelBox.label` + `PixelBox.labelLeftInset` — overlay a widget on the top border with a painter-level carve-out (`[ TITLE ]━━━━━`). `PixelBoxCutout` value object + `PixelShapePainter.labelCutout` let the painter skip the underlying border/fill cells. Builder signature of `PixelShapePainterBuilder` gains an optional named `labelCutout` param; existing custom painters that don't declare it need to be updated (#10). Tuner adds a label editor with live text input.

### Changed
- `PixelBox.style` and `PixelButton.normalStyle` are now optional. When omitted they resolve from the ancestor theme; asserts if neither is available. Existing call sites that pass these props explicitly are unaffected.

## 0.2.1 — 2026-04-23

### Added
- Bundled `MulmaruMono` font family (SIL OFL 1.1) for code, terminal-style UI, and fixed-width layouts.
- `PixelText.mulmaruMono(...)` factory and `PixelText.mulmaruMonoFontFamily` constant. Signature identical to `PixelText.mulmaru(...)`.

### Notes
- Font source: [mushsooni/mulmaru v1.0 release](https://github.com/mushsooni/mulmaru/releases/tag/v1.0). SHA256 `34a1641eb4e94449b26192321e8e0c2bd4f07ef3674fac8abed33d8953a7f70d`.

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
