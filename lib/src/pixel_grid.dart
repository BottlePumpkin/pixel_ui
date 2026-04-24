import 'package:flutter/material.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.gap,
      children: rows,
    );
  }

  Widget _tileFor(int x, int y) {
    final data = widget.tileAt(x, y);
    // null style → _TilePaint renders a placeholder SizedBox.
    final style = data == null ? widget.emptyStyle : widget.styleFor(data);
    return _TilePaint(
      key: ValueKey<(int, int)>((x, y)),
      style: style,
      tileLogicalWidth: widget.tileLogicalWidth,
      tileLogicalHeight: widget.tileLogicalHeight,
      tileScreenSize: widget.tileScreenSize,
    );
  }
}

/// Pure-render leaf. Paints [style] onto a [tileScreenSize] canvas, or emits a
/// same-sized [SizedBox] when [style] is null.
class _TilePaint extends StatelessWidget {
  const _TilePaint({
    super.key,
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
