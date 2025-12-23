import 'package:flutter/material.dart';

class LevelManager {
  int level = 1;

  void update(int score) {
    level = (score ~/ 500) + 1;
  }

  double lockedChance() {
    return (level * 0.01).clamp(0.0, 0.15);
  }

  double complexBlockChance() {
    return (0.15 + level * 0.02).clamp(0.2, 0.45);
  }

  Color gridColor() {
    final hue = (level * 12) % 360;
    return HSVColor.fromAHSV(1, hue.toDouble(), 0.4, 0.25).toColor();
  }

  void reset() {
    level = 1;
  }
}
