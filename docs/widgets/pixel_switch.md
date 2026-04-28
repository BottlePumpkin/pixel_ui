# PixelSwitch

Pixel-styled boolean toggle with sliding thumb. Drop-in replacement for
Material `Switch` inside a pixel-themed app.

## API

```dart
class PixelSwitch extends StatefulWidget {
  const PixelSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onTrackStyle,
    this.offTrackStyle,
    this.thumbStyle,
    this.disabledStyle,
    this.trackLogicalWidth = 24,
    this.trackLogicalHeight = 12,
    this.thumbLogicalSize,
    this.thumbInset = 1,
    this.animationDuration = const Duration(milliseconds: 120),
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final PixelShapeStyle? onTrackStyle;
  final PixelShapeStyle? offTrackStyle;
  final PixelShapeStyle? thumbStyle;
  final PixelShapeStyle? disabledStyle;
  final int trackLogicalWidth;
  final int trackLogicalHeight;
  final int? thumbLogicalSize;
  final int thumbInset;
  final Duration animationDuration;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final bool autofocus;
}
```

## Behavior

- **Default size**: track is `trackLogicalWidth × trackLogicalHeight` logical pixels (`24 × 12` by default → 96 × 48 dp at the standard scale of 4). The thumb defaults to a square sized `trackLogicalHeight - 2 * thumbInset` (`10 × 10` logical → 40 × 40 dp).
- **Thumb position**: when `value == true`, thumb anchors to the right edge with `thumbInset` margin; when `value == false`, anchors to the left edge with the same margin. Switching `value` triggers an `AnimatedPositioned` slide of duration `animationDuration` (default 120 ms, easeOut).
- **Track style swap**: `value == true` paints `onTrackStyle`, `value == false` paints `offTrackStyle`.
- **Tap behavior**:
  - `onChanged == null` OR `enabled == false` → no gesture, no keyboard, but still paints. `Semantics(toggled, isEnabled: false, hasEnabledState: true)`.
  - otherwise → tap fires `onChanged(!value)`. `Semantics(toggled: value, isEnabled: true, hasEnabledState: true, onTap: …)`.
- **Keyboard**: when focused, `LogicalKeyboardKey.space` and `LogicalKeyboardKey.enter` invoke `onChanged(!value)`. Focus is owned by an internal `FocusableActionDetector` unless `focusNode` is supplied.
- **Disabled visual**: when `enabled == false`, the track paints `disabledStyle` if provided; else paints the active (`onTrackStyle` / `offTrackStyle`) style at 50% opacity. The thumb continues to paint `thumbStyle` (under the same opacity wrapper).
- **Theming**: omit any of `onTrackStyle` / `offTrackStyle` / `thumbStyle` / `disabledStyle` to inherit from `PixelSwitchTheme` registered via `pixelUiTheme(...)`. The three required styles (`onTrackStyle`, `offTrackStyle`, `thumbStyle`) assert in debug if neither prop nor theme provides them.

## Style resolution precedence

For each style field, the first source is used:

1. Widget prop on the call site
2. `PixelSwitchTheme.<field>` registered via `pixelUiTheme(switchTheme: …)` or `pixelUiTheme(pixelTheme: PixelTheme(switch_: …))`
3. Assert (for `onTrackStyle` / `offTrackStyle` / `thumbStyle`) — `disabledStyle` falls back to "active style at 50 % opacity" when null

## Examples

### Minimal

```dart
PixelSwitch(
  value: soundOn,
  onChanged: (v) => setState(() => soundOn = v),
  onTrackStyle: PixelShapeStyle(corners: PixelCorners.sm, fillColor: const Color(0xFFFFD643)),
  offTrackStyle: PixelShapeStyle(corners: PixelCorners.sm, fillColor: const Color(0xFF555E73)),
  thumbStyle: PixelShapeStyle(corners: PixelCorners.sm, fillColor: const Color(0xFFFFFFFF)),
);
```

### Themed

```dart
MaterialApp(
  theme: pixelUiTheme(
    switchTheme: PixelSwitchTheme(
      onTrackStyle: panelOn,
      offTrackStyle: panelOff,
      thumbStyle: thumbBase,
    ),
  ),
  home: ...,
);

// Then any descendant uses the theme:
PixelSwitch(
  value: pushOn,
  onChanged: (v) => setState(() => pushOn = v),
  semanticsLabel: '푸시 알림',
);
```

### Disabled with explicit visual

```dart
PixelSwitch(
  value: false,
  onChanged: null,        // OR enabled: false
  onTrackStyle: trackOn,
  offTrackStyle: trackOff,
  thumbStyle: thumbBase,
  disabledStyle: trackDimmed,  // optional — without this, fallback is 50 % opacity
);
```

## Tuner integration

Out of scope for the initial release. The widget composes existing
`PixelShapeStyle` surfaces only, so `tool/check_tuner_coverage.dart`
continues to pass. A dedicated PixelSwitch playground tab in the tuner
is tracked as a follow-up.

## See also

- `PixelListTile` — pairs naturally as the `trailing:` of a settings row
- `PixelButton` — for tap-and-release interactions
- `PixelTheme` — umbrella theme extension that includes `switch_`
