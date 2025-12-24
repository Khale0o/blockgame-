import 'dart:math';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'block_model.dart';
import 'tactical_generator.dart';

class Cell {
  bool occupied;
  bool locked;
  Color? blockColor;

  Cell({
    this.occupied = false,
    this.locked = false,
    this.blockColor,
  });

  void clear() {
    occupied = false;
    blockColor = null;
  }
}

class ScoreManager {
  int currentScore = 0;

  void addScore(int value) {
    currentScore += value;
  }

  void reset() => currentScore = 0;
}

class LevelManager {
  int currentLevel = 1;

  void updateLevel(int score) {
    currentLevel = (score ~/ GameConstants.levelUpThreshold) + 1;
  }

  double difficulty() => (currentLevel * 0.05).clamp(0.0, 0.6);

  void reset() => currentLevel = 1;
}

class PowerUpManager {}

class GameManager {
  final int gridSize = GameConstants.gridSize;
  late List<List<Cell>> grid;

  final Random random = Random();
  final ScoreManager scoreManager;
  final LevelManager levelManager;
  final PowerUpManager powerUpManager;

  final TacticalBlockGenerator blockGenerator = TacticalBlockGenerator();

  List<BlockShape> playerBlocks = [];
  List<bool> usedBlocks = [];

  bool isGameOver = false;
  int comboMultiplier = 1;
int lastClearTick = 0;

  GameManager({
    required this.scoreManager,
    required this.levelManager,
    required this.powerUpManager,
  }) {
   _initGrid();
  generateInitialGrid();
  generatePlayerBlocks();
}

  void _initGrid() {
    grid = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => Cell()),
    );
  }
void generateInitialGrid() {
  final fillRatio = 0.15;
  final totalCells = gridSize * gridSize;
  final cellsToFill = (totalCells * fillRatio).round();

  int placed = 0;

  while (placed < cellsToFill) {
    final x = random.nextInt(gridSize);
    final y = random.nextInt(gridSize);

    if (!grid[y][x].occupied) {
      grid[y][x]
        ..occupied = true
        ..blockColor = const Color.fromARGB(255, 247, 11, 172);
      placed++;
    }
  }

  _breakAccidentalLines();
}

void _breakAccidentalLines() {
  for (int y = 0; y < gridSize; y++) {
    if (grid[y].every((c) => c.occupied)) {
      grid[y][random.nextInt(gridSize)].clear();
    }
  }

  for (int x = 0; x < gridSize; x++) {
    if (List.generate(gridSize, (y) => grid[y][x]).every((c) => c.occupied)) {
      grid[random.nextInt(gridSize)][x].clear();
    }
  }
}

  List<List<bool>> getGridOccupancy() {
    return List.generate(
      gridSize,
      (y) => List.generate(gridSize, (x) => grid[y][x].occupied),
    );
  }

  bool canPlaceBlock(BlockShape block, int row, int col) {
    if (row < 0 ||
        col < 0 ||
        row + block.height > gridSize ||
        col + block.width > gridSize) {
      return false;
    }

    for (final p in block.occupiedCells) {
      final x = col + p.xi;
      final y = row + p.yi;
      if (grid[y][x].occupied) return false;
    }
    return true;
  }

  bool blockFitsAnywhere(BlockShape block) {
    for (int y = 0; y <= gridSize - block.height; y++) {
      for (int x = 0; x <= gridSize - block.width; x++) {
        if (canPlaceBlock(block, y, x)) return true;
      }
    }
    return false;
  }

final TacticalBlockGenerator _generator = TacticalBlockGenerator();

void generatePlayerBlocks() {
  playerBlocks = _generator.generateBlocks(grid);
  usedBlocks = List<bool>.filled(playerBlocks.length, false);
}

  bool placeBlock(int index, int row, int col) {
    if (usedBlocks[index]) return false;

    final block = playerBlocks[index];
    if (!canPlaceBlock(block, row, col)) return false;

    for (final p in block.occupiedCells) {
      final x = col + p.xi;
      final y = row + p.yi;
      grid[y][x]
        ..occupied = true
        ..blockColor = block.color;
    }

    usedBlocks[index] = true;

    _checkCompletedLines();

    scoreManager.addScore(block.occupiedCells.length * 10);
    levelManager.updateLevel(scoreManager.currentScore);

    if (usedBlocks.every((e) => e)) {
      generatePlayerBlocks();
    }

    if (!_anyBlockPlayable()) {
      isGameOver = true;
    }

    return true;
  }

  void _checkCompletedLines() {
  final rows = <int>[];
  final cols = <int>[];

  for (int y = 0; y < gridSize; y++) {
    if (grid[y].every((c) => c.occupied)) rows.add(y);
  }

  for (int x = 0; x < gridSize; x++) {
    if (List.generate(gridSize, (y) => grid[y][x])
        .every((c) => c.occupied)) {
      cols.add(x);
    }
  }

  final cleared = rows.length + cols.length;

  if (cleared > 0) {
    comboMultiplier =
        cleared >= 2 ? comboMultiplier + 1 : 1;

    scoreManager.addScore(
      cleared * gridSize * 5 * comboMultiplier,
    );
  } else {
    comboMultiplier = 1;
  }

  for (final r in rows) {
    for (int x = 0; x < gridSize; x++) {
      grid[r][x].clear();
    }
  }

  for (final c in cols) {
    for (int y = 0; y < gridSize; y++) {
      grid[y][c].clear();
    }
  }
}

  bool _anyBlockPlayable() {
    for (int i = 0; i < playerBlocks.length; i++) {
      if (!usedBlocks[i] && blockFitsAnywhere(playerBlocks[i])) {
        return true;
      }
    }
    return false;
  }

  List<int> getClearedLines() {
    final cleared = <int>[];
    for (int y = 0; y < gridSize; y++) {
      if (grid[y].every((c) => c.occupied)) cleared.add(y);
    }
    return cleared;
  }
}