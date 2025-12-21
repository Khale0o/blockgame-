import 'dart:math';
import 'package:flutter/material.dart';

/// =====================
/// ENUMS
/// =====================

enum BlockType {
  single,
  twoVertical,
  twoHorizontal,
  square,
  lineThree,
  lShape,
  tShape,
  lineFour,
  zigzag,
  cross,
}

enum PowerUpType {
  none,
  bomb,
  lineClear,
  swap,
  hint,
}

/// =====================
/// BLOCK SHAPE
/// =====================

class BlockShape {
  final BlockType type;
  final List<List<bool>> matrix;
  final Color color;
  final PowerUpType powerUp;

  BlockShape({
    required this.type,
    required List<List<bool>> matrix,
    this.powerUp = PowerUpType.none,
    Color? color,
  })  : matrix = _cloneMatrix(matrix),
        color = color ?? _randomColor();

  static List<List<bool>> _cloneMatrix(List<List<bool>> source) {
    return source.map((row) => List<bool>.from(row)).toList();
  }

  static Color _randomColor() {
    final random = Random();
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.cyan,
      Colors.yellow,
    ];
    return colors[random.nextInt(colors.length)];
  }

  int get width => matrix[0].length;
  int get height => matrix.length;

  Iterable<Point<int>> get occupiedCells sync* {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (matrix[y][x]) {
          yield Point(x, y);
        }
      }
    }
  }

  // Copy with optional PowerUp or Color
  BlockShape copyWith({PowerUpType? powerUp, Color? color}) {
    return BlockShape(
      type: type,
      matrix: matrix,
      powerUp: powerUp ?? this.powerUp,
      color: color ?? this.color,
    );
  }

  // =====================
  // PREDEFINED BLOCKS
  // =====================

  static final Map<BlockType, BlockShape> predefined = {
    BlockType.single: BlockShape(
      type: BlockType.single,
      matrix: [
        [true],
      ],
    ),
    BlockType.twoVertical: BlockShape(
      type: BlockType.twoVertical,
      matrix: [
        [true],
        [true],
      ],
    ),
    BlockType.twoHorizontal: BlockShape(
      type: BlockType.twoHorizontal,
      matrix: [
        [true, true],
      ],
    ),
    BlockType.square: BlockShape(
      type: BlockType.square,
      matrix: [
        [true, true],
        [true, true],
      ],
    ),
    BlockType.lineThree: BlockShape(
      type: BlockType.lineThree,
      matrix: [
        [true, true, true],
      ],
    ),
    BlockType.lShape: BlockShape(
      type: BlockType.lShape,
      matrix: [
        [true, false],
        [true, false],
        [true, true],
      ],
    ),
    BlockType.tShape: BlockShape(
      type: BlockType.tShape,
      matrix: [
        [false, true, false],
        [true, true, true],
      ],
    ),
    BlockType.lineFour: BlockShape(
      type: BlockType.lineFour,
      matrix: [
        [true, true, true, true],
      ],
    ),
    BlockType.zigzag: BlockShape(
      type: BlockType.zigzag,
      matrix: [
        [true, true, false],
        [false, true, true],
      ],
    ),
    BlockType.cross: BlockShape(
      type: BlockType.cross,
      matrix: [
        [false, true, false],
        [true, true, true],
        [false, true, false],
      ],
    ),
  };

  static BlockShape randomSimple(Random r) {
    final types = [
      BlockType.single,
      BlockType.twoVertical,
      BlockType.twoHorizontal,
      BlockType.square,
    ];
    return predefined[types[r.nextInt(types.length)]]!.copyWith();
  }

  static BlockShape randomComplex(Random r) {
    final types = [
      BlockType.lineThree,
      BlockType.lShape,
      BlockType.tShape,
      BlockType.lineFour,
      BlockType.zigzag,
      BlockType.cross,
    ];
    return predefined[types[r.nextInt(types.length)]]!.copyWith();
  }
}