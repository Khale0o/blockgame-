// game/logic/block_model.dart
import 'dart:math';
import 'package:flutter/material.dart';

class Vector2 {
  final double x;
  final double y;

  const Vector2(this.x, this.y);

  int get xi => x.toInt();
  int get yi => y.toInt();
}

class BlockShape {
  final List<Vector2> occupiedCells;
  final Color color;
  final int width;
  final int height;
  final bool is3D; // 🔥 جديد
  final double elevation; // 🔥 جديد

  BlockShape({
    required this.occupiedCells,
    required this.color,
    this.is3D = true,
    this.elevation = 3.0,
  })  : width = occupiedCells.map((v) => v.xi).reduce(max) + 1,
        height = occupiedCells.map((v) => v.yi).reduce(max) + 1;

  // ✅ أحصل على نسخة بدون تأثير 3D (للعرض في الجريد)
  BlockShape get flatVersion => BlockShape(
        occupiedCells: occupiedCells,
        color: color,
        is3D: false,
        elevation: 0,
      );

  // ✅ توليد ألوان متدرجة لتأثير 3D
  Color get topColor => Color.lerp(color, Colors.white, 0.2)!;
  Color get sideColor => Color.lerp(color, Colors.black, 0.3)!;
  Color get baseColor => color;

  BlockShape copyWithRandomRemoval(Random random, int cellsToRemove) {
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
    final simpleShapes = [
      BlockShape(
        occupiedCells: [Vector2(0, 0)],
        color: _getRandomColor(random),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(1, 0)],
        color: _getRandomColor(random),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(0, 1)],
        color: _getRandomColor(random),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)],
        color: _getRandomColor(random),
      ),
    ];
    return simpleShapes[random.nextInt(simpleShapes.length)];
  }

  static BlockShape randomComplex(Random random) {
    final complexShapes = [
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0),
          Vector2(0, 1), Vector2(1, 1),
        ],
        color: _getRandomColor(random),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
          Vector2(1, 1),
        ],
        color: _getRandomColor(random),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(0, 0),
          Vector2(0, 1),
          Vector2(1, 1),
          Vector2(2, 1),
        ],
        color: _getRandomColor(random),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0),
          Vector2(1, 1), Vector2(2, 1),
        ],
        color: _getRandomColor(random),
      ),
    ];
    return complexShapes[random.nextInt(complexShapes.length)];
  }

  static Color _getRandomColor(Random random) {
    final colors = [
      Color(0xFFF44336), // Red
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFF9C27B0), // Purple
      Color(0xFF00BCD4), // Cyan
      Color(0xFFFFEB3B), // Yellow
      Color(0xFFE91E63), // Pink
      Color(0xFF795548), // Brown
      Color(0xFF607D8B), // Blue Grey
      Color(0xFF8BC34A), // Light Green
      Color(0xFFFF5722), // Deep Orange
    ];
    return colors[random.nextInt(colors.length)];
  }
}