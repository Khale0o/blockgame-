import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class LevelManager {
  int currentLevel;
  int scoreThreshold;
  
  LevelManager({
    this.currentLevel = GameConstants.initialLevel,
    this.scoreThreshold = GameConstants.levelUpThreshold,
  });
  
  void updateLevel(int score) {
    final newLevel = (score ~/ scoreThreshold) + 1;
    if (newLevel > currentLevel) {
      currentLevel = newLevel;
      // Increase threshold for next level
      scoreThreshold = currentLevel * GameConstants.levelUpThreshold;
    }
  }
  
  double getLockedCellProbability() {
    // Gradually increase locked cells up to 15% at level 20
    return (currentLevel * 0.0075).clamp(0.0, 0.15);
  }
  
  double getComplexBlockProbability() {
    // Increase complex blocks up to 40% at level 20
    return (currentLevel * 0.02).clamp(0.1, 0.4);
  }
  
  Color getGridColor() {
    // Change grid color based on level
    final hue = (currentLevel * 10) % 360;
    return HSVColor.fromAHSV(1.0, hue.toDouble(), 0.3, 0.2).toColor();
  }
  
  void reset() {
    currentLevel = GameConstants.initialLevel;
    scoreThreshold = GameConstants.levelUpThreshold;
  }
}