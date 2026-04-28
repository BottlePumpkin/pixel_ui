# PixelSlider

Pixel-styled value slider (continuous or discrete). Drop-in replacement for
Material `Slider` inside a pixel-themed app.

## API

```dart
class PixelSlider extends StatefulWidget {
  const PixelSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.trackStyle,
    this.fillStyle,
    this.thumbStyle,
    this.disabledStyle,
    this.trackLogicalWidth = 80,
    this.trackLogicalHeight = 4,
    this.thumbLogicalSize = 8,
    this.keyboardStep,
    this.pageStep,
    this.semanticsLabel,
    this.semanticsValueText,
    this.focusNode,
    this.autofocus = false,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final double min;
  final double max;
  final int? divisions;
  final PixelShapeStyle? trackStyle;
  final PixelShapeStyle? fillStyle;
  final PixelShapeStyle? thumbStyle;
  final PixelShapeStyle? disabledStyle;
  final int trackLogicalWidth;
  final int trackLogicalHeight;
  final int thumbLogicalSize;
  final double? keyboardStep;
  final double? pageStep;
  final String? semanticsLabel;
  final String Function(double value)? semanticsValueText;
  final FocusNode? focusNode;
  final bool autofocus;
}
```

## Behavior

- **Geometry (iOS-style)**: thumb is fully within the track widget bounds. At `value == min` the thumb anchors to the track's left edge (left=0); at `value == max` the thumb anchors to the right edge (left = trackWidth − thumbWidth). The fill spans from the track's left edge to the thumb's right edge, so the visible "filled" portion is proportional to `(value − min) / (max − min)`.
- **Stretch**: the slider always fills the available horizontal space (internal `LayoutBuilder` passes `width: constraints.maxWidth` to the track/fill `PixelBox`es). Vertical size = `max(trackLogicalHeight, thumbLogicalSize) × 4` dp.
- **Tap & drag**: both go through `_setValueFromDx(localDx, trackWidth)`, which maps the x-coordinate to `[min, max]`, clamps, and snaps to the nearest division when `divisions != null`. The widget calls `onChanged(newValue)` only if the rounded value actually changed (to avoid redundant rebuild storms).
- **Divisions**:
  - `divisions == null` → continuous; `value` may take any double in `[min, max]`.
  - `divisions == N` → snap to one of `N + 1` evenly-spaced steps: `min, min+(max-min)/N, …, max`.
- **Keyboard** (when focused):
  - Arrow Left / Down → decrement by `keyboardStep` (or default).
  - Arrow Right / Up → increment by `keyboardStep` (or default).
  - PageDown → decrement by `pageStep` (or default).
  - PageUp → increment by `pageStep` (or default).
  - Defaults — `keyboardStep`: `(max − min) / divisions` for discrete, else `(max − min) / 20`. `pageStep`: `(max − min) / 4` for continuous, else `max(keyboardStep, (max − min) / 10)` for discrete.
- **Disabled visual**: when `enabled == false`, the track paints `disabledStyle` if provided; else the entire visual subtree (track + fill + thumb) is wrapped in `Opacity(0.5)`. Tap/drag/keyboard are blocked.
- **Theming**: omit any of `trackStyle` / `fillStyle` / `thumbStyle` / `disabledStyle` to inherit from `PixelSliderTheme` registered via `pixelUiTheme(...)`. The three required styles (`trackStyle`, `fillStyle`, `thumbStyle`) assert in debug if neither prop nor theme provides them.
- **Semantics**: outermost `Semantics(slider: true, label: semanticsLabel, value: text, increasedValue: textForIncrement, decreasedValue: textForDecrement, onIncrease: …, onDecrease: …)`. Value text is computed by `semanticsValueText(widget.value)` when set, else `'${((widget.value - min) / (max - min) * 100).round()}%'` for the default `[0, 1]` range, else `widget.value.toString()` for other ranges.

## Style resolution precedence

For each style field, the first source is used:

1. Widget prop on the call site
2. `PixelSliderTheme.<field>` registered via `pixelUiTheme(sliderTheme: …)` or `pixelUiTheme(pixelTheme: PixelTheme(slider: …))`
3. Assert (for `trackStyle` / `fillStyle` / `thumbStyle`) — `disabledStyle` falls back to "active styles at 50 % opacity" when null

## Examples

### Volume slider (continuous, 0–1)

```dart
PixelSlider(
  value: volume,
  onChanged: (v) => setState(() => volume = v),
  trackStyle: PixelShapeStyle(corners: PixelCorners.sm, fillColor: const Color(0xFF222732)),
  fillStyle: PixelShapeStyle(corners: PixelCorners.sm, fillColor: const Color(0xFFFFD643)),
  thumbStyle: PixelShapeStyle(corners: PixelCorners.sm, fillColor: const Color(0xFFFFFFFF)),
  semanticsLabel: '볼륨',
);
```

### Difficulty (discrete, 5 steps)

```dart
PixelSlider(
  value: difficulty.toDouble(),
  onChanged: (v) => setState(() => difficulty = v.round()),
  min: 1,
  max: 5,
  divisions: 4,        // (max-min)/divisions = 1 step
  trackStyle: trackBase,
  fillStyle: fillBase,
  thumbStyle: thumbBase,
  semanticsLabel: '난이도',
  semanticsValueText: (v) => '난이도 ${v.round()}',
);
```

### Disabled

```dart
PixelSlider(
  value: 0.5,
  onChanged: null,    // OR enabled: false
  trackStyle: trackBase,
  fillStyle: fillBase,
  thumbStyle: thumbBase,
  disabledStyle: trackDimmed,  // optional — without this, fallback is 50 % opacity
);
```

## Tuner integration

Out of scope for the initial release. The widget composes existing
`PixelShapeStyle` surfaces only, so `tool/check_tuner_coverage.dart`
continues to pass. A dedicated PixelSlider playground tab is tracked as a
follow-up.

## See also

- `PixelSwitch` — boolean toggle counterpart
- `PixelListTile` — pairs naturally as the `trailing:` of a settings row when the slider is full-width below
- `PixelTheme` — umbrella theme extension that includes `slider`
