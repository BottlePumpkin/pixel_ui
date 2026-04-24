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
  // ignore: prefer_const_constructors_in_immutables
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
        assert(data.every((row) => row.length == data[0].length),
            'PixelGrid.fromList: all rows must have the same length'),
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

  final int rows;
  final int cols;
  final T? Function(int x, int y) tileAt;

  final int tileLogicalWidth;
  final int tileLogicalHeight;
  final Size tileScreenSize;
  final double gap;

  final PixelShapeStyle Function(T data) styleFor;
  final PixelShapeStyle? emptyStyle;

  final T? Function(int x, int y)? dragDataFor;
  final void Function(int x, int y)? onTileTap;
  final void Function(int x, int y)? onTileActivate;
  final void Function((int, int) from, (int, int) to, T data)? onTileAccept;

  final bool Function(int x, int y)? isTileEnabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<PixelGrid<T>> createState() => _PixelGridState<T>();
}

class _PixelGridState<T> extends State<PixelGrid<T>> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // replaced in Task 2
  }
}
