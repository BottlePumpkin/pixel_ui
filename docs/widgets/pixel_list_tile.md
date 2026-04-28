# PixelListTile

Pixel-styled row layout for settings / profile / menu screens.

## API

```dart
class PixelListTile extends StatefulWidget {
  const PixelListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.style,
    this.pressedStyle,
    this.disabledStyle,
    this.contentPadding,
    this.slotGap,
    this.logicalWidth = 80,
    this.logicalHeight = 14,
    this.pressChildOffset = const Offset(0, 1),
    this.semanticsLabel,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final PixelShapeStyle? style;
  final PixelShapeStyle? pressedStyle;
  final PixelShapeStyle? disabledStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double? slotGap;
  final int logicalWidth;
  final int logicalHeight;
  final Offset pressChildOffset;
  final String? semanticsLabel;
}
```

## Behavior

- **Stretch**: always fills the available horizontal space (internal `LayoutBuilder` passes `width: constraints.maxWidth` to the inner `PixelBox`). Vertical size = `logicalHeight × 4` dp by default.
- **Slot composition** (left → right): `leading?` · gap · `Expanded(Column(title [, subtitle]))` · gap · `trailing?`. Default gap = 12 dp; override via `slotGap`.
- **Content padding**: defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`. Override via `contentPadding`.
- **Tap & press**:
  - `onTap == null` → informational tile, no gesture detector, `Semantics(button: false)`.
  - `onTap != null && enabled` → `GestureDetector` + `Semantics(button: true, enabled: true)`. While pressed: paints `pressedStyle` (if provided, else keeps `style`) and slides children by `pressChildOffset` via `AnimatedSlide`.
  - `onTap != null && !enabled` → `Semantics(button: true, enabled: false)`. No tap fires.
- **Disabled visual**: when `enabled == false`, paints `disabledStyle` if provided, else paints `style` at 50% opacity (matches `PixelButton`).
- **Theming**: omit any of `style` / `pressedStyle` / `disabledStyle` / `contentPadding` / `slotGap` to inherit from `PixelListTileTheme` registered via `pixelUiTheme(...)`. `style` asserts in debug if neither prop nor theme provides it. `logicalWidth` / `logicalHeight` defaults are widget-level only (theme has no override slot for them — keeps tile rhythm uniform within an app).

## Style resolution precedence

For each style/padding/gap field, the first source is used:

1. Widget prop on the call site
2. `PixelListTileTheme.<field>` registered via `pixelUiTheme(listTileTheme: ...)` or `pixelUiTheme(pixelTheme: PixelTheme(listTile: ...))`
3. Built-in default (for `contentPadding` and `slotGap` only)
4. Assert (for `style` only — required field)

## Examples

### Minimal informational row

```dart
PixelListTile(
  style: panelStyle,
  title: Text('효과음', style: PixelText.mulmaru(fontSize: 14)),
  subtitle: Text('버튼·알림 픽셀 사운드',
      style: PixelText.mulmaru(fontSize: 11, color: Colors.white70)),
  trailing: Text('ON', style: PixelText.mulmaruMono(fontSize: 12)),
);
```

### Tappable settings row (with theme)

```dart
MaterialApp(
  theme: pixelUiTheme(
    listTileTheme: PixelListTileTheme(style: panelStyle, pressedStyle: pressedStyle),
  ),
  home: Scaffold(body: ListView(children: [
    PixelListTile(
      title: Text('알림 설정', style: PixelText.mulmaru(fontSize: 14)),
      trailing: Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, '/notifications'),
    ),
    PixelListTile(
      title: Text('프로필', style: PixelText.mulmaru(fontSize: 14)),
      onTap: () => Navigator.pushNamed(context, '/profile'),
    ),
  ])),
);
```

### Disabled row with explicit visual

```dart
PixelListTile(
  style: panelStyle,
  disabledStyle: panelStyle.copyWith(fillColor: const Color(0xFF222732)),
  enabled: false,
  title: Text('베타 기능', style: PixelText.mulmaru(fontSize: 14)),
  subtitle: Text('곧 출시 예정',
      style: PixelText.mulmaru(fontSize: 11, color: Colors.white38)),
  onTap: () {}, // ignored while enabled: false
);
```

## See also

- `PixelBox` — underlying container (this widget composes one)
- `PixelButton` — for button-shaped interactions (this is row-shaped)
- `PixelTheme` — umbrella theme extension that includes `listTile`
