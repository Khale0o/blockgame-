// game/logic/hint_manager.dart
import 'dart:math';
import 'package:blickgame/game/logic/block_model.dart';

import 'game_manager.dart';

class HintManager {
  final GameManager gameManager;
  final Random _random = Random();

  HintManager(this.gameManager);

  List<PlacementHint> getBestPlacements(BlockShape block) {
    final List<PlacementHint> hints = [];

    for (int y = 0; y <= gameManager.gridSize - block.height; y++) {
      for (int x = 0; x <= gameManager.gridSize - block.width; x++) {
        if (gameManager.canPlaceBlock(block, y, x)) {
          final score = _evaluatePlacement(block, y, x);
          hints.add(PlacementHint(x, y, score));
        }
      }
    }

    if (hints.isEmpty) return [];

    hints.sort((a, b) => b.score.compareTo(a.score));

    final top = hints.take(min(5, hints.length)).toList();
    top.shuffle(_random);

    return top.take(3).toList();
  }

  // ================= SCORING =================
  int _evaluatePlacement(BlockShape block, int row, int col) {
    final tempGrid = _copyGrid(gameManager.grid);

    for (final p in block.occupiedCells) {
      final x = (col + p.x).toInt(); // ✅ تحويل إلى int
      final y = (row + p.y).toInt(); // ✅ تحويل إلى int
      if (y >= 0 && y < tempGrid.length && x >= 0 && x < tempGrid[0].length) {
        tempGrid[y][x].occupied = true;
      }
    }

    int score = 0;
    score += _countCompletedLines(tempGrid) * 100;
    score += block.occupiedCells.length * 2;
    score -= _countIsolatedHoles(tempGrid) * 5;

    if (row == 0 || col == 0) score -= 4;
    score += _random.nextInt(6);

    return score;
  }

  int _countCompletedLines(List<List<Cell>> grid) {
    int lines = 0;
    final size = grid.length;

    for (int y = 0; y < size; y++) {
      if (grid[y].every((c) => c.occupied && !c.locked)) lines++;
    }

    for (int x = 0; x < size; x++) {
      bool full = true;
      for (int y = 0; y < size; y++) {
        if (!grid[y][x].occupied || grid[y][x].locked) {
          full = false;
          break;
        }
      }
      if (full) lines++;
    }

    return lines;
  }

  int _countIsolatedHoles(List<List<Cell>> grid) {
    int holes = 0;
    final size = grid.length;

    for (int y = 1; y < size - 1; y++) {
      for (int x = 1; x < size - 1; x++) {
        if (!grid[y][x].occupied &&
            grid[y - 1][x].occupied &&
            grid[y + 1][x].occupied &&
            grid[y][x - 1].occupied &&
            grid[y][x + 1].occupied) {
          holes++;
        }
      }
    }
    return holes;
  }

  List<List<Cell>> _copyGrid(List<List<Cell>> original) {
    return List.generate(
      original.length,
      (y) => List.generate(
        original[y].length,
        (x) => Cell(
          occupied: original[y][x].occupied,
          locked: original[y][x].locked,
          blockColor: original[y][x].blockColor,
        ),
      ),
    );
  }
}

// ================= MODEL =================
class PlacementHint {
  final int x;
  final int y;
  final int score;

  PlacementHint(this.x, this.y, this.score);
}