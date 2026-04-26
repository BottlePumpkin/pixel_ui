import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pixel_ui/src/pixel_shape_painter.dart';
import 'package:pixel_ui/src/pixel_style.dart';

/// Tile-based layout widget backed by [PixelShapePainter].
///
/// Use [PixelGrid.fromList] for static 2D data, or [PixelGrid.builder] for
/// dynamic / procedural tiles. Data indexing convention: `data[y][x]` —
/// outer list = rows, inner list = columns. `null` data = empty slot.
class PixelGrid<T> extends StatefulWidget {
  /// Static 2D data. `data[y][x] == null` leaves the slot empty.
  PixelGrid.fromList({
    super.key,
    required List<List<T?>> data,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.styleFor,
    this.emptyStyle,
    this.dragDataFor,
    this.onTileTap,
    this.onTileActivate,
    this.onTileAccept,
    this.isTileEnabled,
    this.autofocus = false,
    this.focusNode,
    this.gap = 0,
  })  : assert(data.isNotEmpty, 'PixelGrid.fromList: data must not be empty'),
        assert(data[0].isNotEmpty,
            'PixelGrid.fromList: data rows must not be empty'),
        assert(
          data.every((row) => row.length == data[0].length),
          'PixelGrid.fromList: all rows must have length ${data[0].length}',
        ),
        assert(tileLogicalWidth > 0, 'tileLogicalWidth must be positive'),
        assert(tileLogicalHeight > 0, 'tileLogicalHeight must be positive'),
        assert(dragDataFor != null || onTileAccept == null,
            'onTileAccept requires dragDataFor so tiles can be drag sources'),
        rows = data.length,
        cols = data[0].length,
        tileAt = ((int x, int y) => data[y][x]);

  /// Procedural builder. [rows] × [cols]; [tileAt] returns the data at a
  /// given cell (`null` = empty slot).
  // ignore: prefer_const_constructors_in_immutables
  PixelGrid.builder({
    super.key,
    required this.rows,
    required this.cols,
    required this.tileAt,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.styleFor,
    this.emptyStyle,
    this.dragDataFor,
    this.onTileTap,
    this.onTileActivate,
    this.onTileAccept,
    this.isTileEnabled,
    this.autofocus = false,
    this.focusNode,
    this.gap = 0,
  })  : assert(rows > 0, 'rows must be positive'),
        assert(cols > 0, 'cols must be positive'),
        assert(tileLogicalWidth > 0, 'tileLogicalWidth must be positive'),
        assert(tileLogicalHeight > 0, 'tileLogicalHeight must be positive'),
        assert(dragDataFor != null || onTileAccept == null,
            'onTileAccept requires dragDataFor so tiles can be drag sources');

  // Rendering
  final int rows;
  final int cols;
  final T? Function(int x, int y) tileAt;

  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;

  final PixelShapeStyle Function(T data) styleFor;
  final PixelShapeStyle? emptyStyle;
  final double gap;

  // Interaction
  final T? Function(int x, int y)? dragDataFor;
  final void Function(int x, int y)? onTileTap;
  final void Function(int x, int y)? onTileActivate;
  final void Function((int, int) from, (int, int) to, T data)? onTileAccept;

  // Keyboard
  final bool Function(int x, int y)? isTileEnabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<PixelGrid<T>> createState() => _PixelGridState<T>();
}

class _PixelGridState<T> extends State<PixelGrid<T>> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  (int, int) _focused = (0, 0);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
  }

  @override
  void didUpdateWidget(covariant PixelGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
    }
    // Clamp focus into new bounds if grid shrank.
    final (fx, fy) = _focused;
    if (fx >= widget.cols || fy >= widget.rows) {
      _focused = (
        fx.clamp(0, widget.cols - 1),
        fy.clamp(0, widget.rows - 1),
      );
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  bool _isEnabled(int x, int y) =>
      widget.isTileEnabled?.call(x, y) ?? true;

  void _moveFocusBy(int dx, int dy) {
    final (fx, fy) = _focused;
    int nx = fx + dx;
    int ny = fy + dy;
    // Skip disabled tiles; stop at boundary without wrapping.
    while (nx >= 0 && nx < widget.cols && ny >= 0 && ny < widget.rows) {
      if (_isEnabled(nx, ny)) {
        setState(() => _focused = (nx, ny));
        return;
      }
      nx += dx;
      ny += dy;
    }
    // No enabled target in that direction: stay put.
  }

  void _moveFocusTo(int x, int y) {
    if (_focused == (x, y)) return;
    if (!_isEnabled(x, y)) return;
    setState(() => _focused = (x, y));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _moveFocusBy(0, -1);
      case LogicalKeyboardKey.arrowDown:
        _moveFocusBy(0, 1);
      case LogicalKeyboardKey.arrowLeft:
        _moveFocusBy(-1, 0);
      case LogicalKeyboardKey.arrowRight:
        _moveFocusBy(1, 0);
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        final (fx, fy) = _focused;
        final data = widget.tileAt(fx, fy);
        if (data != null && widget.onTileActivate != null) {
          widget.onTileActivate!(fx, fy);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int y = 0; y < widget.rows; y++) {
      final tiles = <Widget>[];
      for (int x = 0; x < widget.cols; x++) {
        tiles.add(_tileFor(x, y));
      }
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        spacing: widget.gap,
        children: tiles,
      ));
    }
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: widget.gap,
        children: rows,
      ),
    );
  }

  Widget _tileFor(int x, int y) {
    final data = widget.tileAt(x, y);
    // null style → _TilePaint renders a placeholder SizedBox.
    final style = data == null ? widget.emptyStyle : widget.styleFor(data);
    return _Tile<T>(
      key: ValueKey<(int, int)>((x, y)),
      x: x,
      y: y,
      data: data,
      style: style,
      tileLogicalWidth: widget.tileLogicalWidth,
      tileLogicalHeight: widget.tileLogicalHeight,
      tileScreenSize: widget.tileScreenSize,
      onTileTap: widget.onTileTap == null
          ? null
          : (tx, ty) {
              widget.onTileTap!(tx, ty);
              _moveFocusTo(tx, ty);
              _focusNode.requestFocus();
            },
      focused: _focused == (x, y),
    );
  }
}

class _Tile<T> extends StatelessWidget {
  const _Tile({
    super.key,
    required this.x,
    required this.y,
    required this.data,
    required this.style,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
    required this.focused,
    this.onTileTap,
  });

  final int x;
  final int y;
  final T? data;
  final PixelShapeStyle? style;
  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;
  final bool focused;
  final void Function(int x, int y)? onTileTap;

  @override
  Widget build(BuildContext context) {
    final paint = _TilePaint(
      style: style,
      tileLogicalWidth: tileLogicalWidth,
      tileLogicalHeight: tileLogicalHeight,
      tileScreenSize: tileScreenSize,
    );
    Widget tile = focused
        ? Stack(children: [paint, _FocusOutline(size: tileScreenSize)])
        : paint;
    if (onTileTap != null) {
      tile = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTileTap!(x, y),
        child: tile,
      );
    }
    return tile;
  }
}

class _FocusOutline extends StatelessWidget {
  const _FocusOutline({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
          ),
        ),
      ),
    );
  }
}

/// Pure-render leaf. Paints [style] onto a [tileScreenSize] canvas, or emits a
/// same-sized [SizedBox] when [style] is null.
class _TilePaint extends StatelessWidget {
  const _TilePaint({
    required this.style,
    required this.tileLogicalWidth,
    required this.tileLogicalHeight,
    required this.tileScreenSize,
  });

  final PixelShapeStyle? style;
  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;

  @override
  Widget build(BuildContext context) {
    final style = this.style;
    if (style == null) {
      return SizedBox(width: tileScreenSize.width, height: tileScreenSize.height);
    }
    return CustomPaint(
      size: tileScreenSize,
      painter: PixelShapePainter(
        logicalWidth: tileLogicalWidth,
        logicalHeight: tileLogicalHeight,
        style: style,
      ),
    );
  }
}
