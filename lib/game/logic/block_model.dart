import 'dart:math';
import 'package:flutter/material.dart';

class Vector2 {
  final double x;
  final double y;

  const Vector2(this.x, this.y);

  int get xi => x.toInt();
  int get yi => y.toInt();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector2 && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

class BlockShape {
  final List<Vector2> occupiedCells;
  final Color color;

  final bool is3D;
  final double elevation;

  final int width;
  final int height;

  BlockShape({
    required this.occupiedCells,
    required this.color,
    this.is3D = true,
    this.elevation = 3.0,
  })  : width =
            occupiedCells.map((v) => v.xi).reduce(max) + 1,
        height =
            occupiedCells.map((v) => v.yi).reduce(max) + 1;

  BlockShape get flatVersion => BlockShape(
        occupiedCells: occupiedCells,
        color: color,
        is3D: false,
        elevation: 0,
      );

  Color get topColor =>
      Color.lerp(color, Colors.white, 0.25)!;

  Color get sideColor =>
      Color.lerp(color, Colors.black, 0.35)!;

  Color get baseColor => color;

  BlockShape copyWithRandomRemoval(
    Random random,
    int cellsToRemove,
  ) {
    if (occupiedCells.length <= cellsToRemove) return this;

    final newCells = List<Vector2>.from(occupiedCells);
    for (int i = 0; i < cellsToRemove; i++) {
      if (newCells.length > 1) {
        newCells.removeAt(random.nextInt(newCells.length));
      }
    }

    return BlockShape(
      occupiedCells: newCells,
      color: color,
      is3D: is3D,
      elevation: elevation,
    );
  }

  static BlockShape randomSimple(Random random) {
    final shapes = _simpleShapes;
    final cells = shapes[random.nextInt(shapes.length)];

    return BlockShape(
      occupiedCells: cells,
      color: _randomColor(random),
    );
  }

  static BlockShape randomMedium(Random random) {
    final shapes = _mediumShapes;
    final cells = shapes[random.nextInt(shapes.length)];

    return BlockShape(
      occupiedCells: cells,
      color: _randomColor(random),
    );
  }

  static BlockShape randomComplex(Random random) {
    final shapes = _complexShapes;
    final cells = shapes[random.nextInt(shapes.length)];

    return BlockShape(
      occupiedCells: cells,
      color: _randomColor(random),
    );
  }

  static const List<List<Vector2>> _simpleShapes = [
    [Vector2(0, 0)],
    [Vector2(0, 0), Vector2(1, 0)],
    [Vector2(0, 0), Vector2(0, 1)],
    [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)],
  ];

  static const List<List<Vector2>> _mediumShapes = [
    [
      Vector2(0, 0),
      Vector2(1, 0),
      Vector2(2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, 1),
      Vector2(0, 2),
    ],
    [
      Vector2(0, 0),
      Vector2(1, 0),
      Vector2(0, 1),
      Vector2(1, 1),
    ],
    [
      Vector2(0, 0),
      Vector2(1, 0),
      Vector2(2, 0),
      Vector2(1, 1),
    ],
  ];

  static const List<List<Vector2>> _complexShapes = [
    [
      Vector2(0, 0),
      Vector2(1, 0),
      Vector2(1, 1),
      Vector2(2, 1),
    ],
    [
      Vector2(0, 1),
      Vector2(1, 1),
      Vector2(2, 1),
      Vector2(2, 0),
    ],
    [
      Vector2(0, 0),
      Vector2(0, 1),
      Vector2(1, 1),
      Vector2(2, 1),
    ],
  ];

  static Color _randomColor(Random random) {
    const colors = [
      Color(0xFFF44336),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
      Color(0xFFFFEB3B),
      Color(0xFFE91E63),
      Color(0xFF795548),
      Color(0xFF607D8B),
    ];
    return colors[random.nextInt(colors.length)];
  }
}