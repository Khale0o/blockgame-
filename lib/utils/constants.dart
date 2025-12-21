import 'package:flutter/material.dart';

class GameConstants {
  // Grid Configuration
  static const int gridSize = 10;
  static const double cellSize = 40.0;
  static const double blockPadding = 2.0;
  
  // Game Balance
  static const int initialLevel = 1;
  static const int scorePerCell = 10;
  static const int levelUpThreshold = 1000;
  
  // Visual Constants
  static const Color emptyCellColor = Color(0xFF2D3047);
  static const Color occupiedCellColor = Color(0xFF419D78);
  static const Color lockedCellColor = Color(0xFF5D576B);
  static const Color gridLineColor = Color(0x44FFFFFF);
  
  // Block Colors
  static const List<Color> blockColors = [
    Color(0xFF419D78), // Green
    Color(0xFFE0A458), // Orange
    Color(0xFFDB5461), // Red
    Color(0xFF685DC5), // Purple
    Color(0xFF57A773), // Teal
    Color(0xFFF06543), // Coral
    Color(0xFF4A90E2), // Blue
  ];
  
  // Animation Durations
  static const Duration placementAnimation = Duration(milliseconds: 200);
  static const Duration lineClearAnimation = Duration(milliseconds: 800);
  static const Duration levelTransition = Duration(milliseconds: 500);
  
  // Power-up probabilities (per level)
  static double getPowerUpProbability(int level) {
    return 0.05 + (level * 0.005);
  }
  
  // Block complexity weights by level
  static List<double> getBlockWeights(int level) {
    final double complexity = (level - 1) * 0.1;
    return [
      1.0 - complexity * 0.5, // Simple blocks
      0.3 + complexity * 0.3,  // Medium blocks
      0.1 + complexity * 0.2,  // Complex blocks
    ];
  }
}