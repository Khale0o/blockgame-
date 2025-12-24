import 'dart:math';
import 'package:flutter/material.dart';

import 'block_model.dart';
import 'game_manager.dart';

class TacticalBlockGenerator {
  final Random _random = Random();

  List<BlockShape> generateBlocks(List<List<Cell>> grid) {
    final freeRatio = _analyzeFreeSpace(grid);

    final List<BlockShape> blocks = [];

    blocks.add(_generateSimple());
    blocks.add(_generateMedium());

    if (freeRatio < 0.35) {
      blocks.add(_generateSimple());
    } else if (freeRatio < 0.55) {
      blocks.add(_generateMedium());
    } else {
      blocks.add(_generateComplex());
    }

    return blocks;
  }

  double _analyzeFreeSpace(List<List<Cell>> grid) {
    int free = 0;
    int total = 0;

    for (final row in grid) {
      for (final c in row) {
        total++;
        if (!c.occupied) free++;
      }
    }

    return free / total;
  }

  BlockShape _generateSimple() {
    return BlockShape.randomSimple(_random);
  }

  BlockShape _generateMedium() {
    return BlockShape.randomMedium(_random);
  }

  BlockShape _generateComplex() {
    return BlockShape.randomComplex(_random);
  }
}