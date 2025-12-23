import 'package:flutter/material.dart';

class GameConstants {
  // =====================
  // GRID CONFIGURATION (Block Blast Style)
  // =====================
  static const int gridSize = 8; // ✅ 8x8
  static const double cellSize = 42.0; // حجم مريح للموبايل
  static const double blockPadding = 3.0;

  // =====================
  // GAME BALANCE
  // =====================
  static const int initialLevel = 1;
  static const int scorePerCell = 10;
  static const int levelUpThreshold = 800; // أسرع شوية زي Block Blast

  // =====================
  // VISUAL COLORS
  // =====================
  static const Color emptyCellColor = Color(0xFF1E1E2C);
  static const Color occupiedCellColor = Color(0xFF4CAF50);
  static const Color lockedCellColor = Color(0xFF3A3A4D);
  static const Color gridLineColor = Color.fromARGB(181, 255, 255, 255);

  // =====================
  // BLOCK COLORS (Vibrant)
  // =====================
  static const List<Color> blockColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Yellow
    Color(0xFFFF7043), // Orange
    Color(0xFFEC407A), // Pink
    Color(0xFF7E57C2), // Purple
    Color(0xFF29B6F6), // Blue
    Color(0xFF26A69A), // Teal
  ];

  // =====================
  // ANIMATION DURATIONS
  // =====================
  static const Duration placementAnimation =
      Duration(milliseconds: 140); // Snappy
  static const Duration lineClearAnimation =
      Duration(milliseconds: 420); // Pop feel
  static const Duration levelTransition =
      Duration(milliseconds: 300);

  // =====================
  // POWER-UP SPAWN RATE
  // =====================
  static double getPowerUpProbability(int level) {
    // ناعم – من غير سبام
    return (0.04 + (level * 0.004)).clamp(0.04, 0.15);
  }

  // =====================
  // BLOCK COMPLEXITY WEIGHTS
  // =====================
  static List<double> getBlockWeights(int level) {
    final double difficulty = (level - 1) * 0.08;

    return [
      (1.0 - difficulty).clamp(0.4, 1.0), // Simple
      (0.3 + difficulty * 0.6).clamp(0.3, 0.8), // Medium
      (0.1 + difficulty * 0.5).clamp(0.1, 0.6), // Complex
    ];
  }
}
