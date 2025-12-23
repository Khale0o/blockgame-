import 'package:flutter/material.dart';

class GameConstants {
  static const int gridSize = 8;
  static const double cellSize = 42.0;
  static const double blockPadding = 4.0;

  // 🎨 Background
  static const Color backgroundColor = Color(0xFF3B3B7A);

  // 🧱 Grid
  static const Color emptyCellColor = Color(0xFF2F2F55);
  static const Color occupiedCellColor = Color(0xFF5AC18E);
  static const Color lockedCellColor = Color(0xFF242445);
  static const Color gridLineColor = Color.fromARGB(60, 255, 255, 255);

  // 🟦 Blocks – Soft Vibrant
  static const List<Color> blockColors = [
    Color(0xFF6FCF97),
    Color(0xFFF2C94C),
    Color(0xFFF2994A),
    Color(0xFFEB5757),
    Color(0xFF9B51E0),
    Color(0xFF56CCF2),
    Color(0xFF2D9CDB),
  ];

  static const int initialLevel = 1;
  static const int scorePerCell = 10;
  static const int levelUpThreshold = 800;

  static const Duration placementAnimation =
      Duration(milliseconds: 140);
  static const Duration lineClearAnimation =
      Duration(milliseconds: 420);
  static const Duration levelTransition =
      Duration(milliseconds: 300);
}
