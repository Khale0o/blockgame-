// game/logic/game_manager.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'block_model.dart';
import 'tactical_generator.dart';
import 'enums.dart';

class Cell {
  bool occupied;
  bool locked;
  Color? blockColor;

  Cell({this.occupied = false, this.locked = false, this.blockColor});

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

  double difficulty() => (currentLevel * 0.05).clamp(0.0, 0.5);

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

  List<BlockShape> playerBlocks = [];
  List<bool> usedBlocks = [];

  bool isGameOver = false;

  GameManager({
    required this.scoreManager,
    required this.levelManager,
    required this.powerUpManager,
  }) {
    _initGrid();
    generatePlayerBlocks();
  }

  void _initGrid() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => Cell()));
  }

  List<List<bool>> getGridOccupancy() {
    return List.generate(gridSize, (y) => List.generate(gridSize, (x) => grid[y][x].occupied));
  }

  bool canPlaceBlock(BlockShape block, int row, int col) {
    if (row < 0 || col < 0 || row + block.height > gridSize || col + block.width > gridSize) return false;
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

  void generatePlayerBlocks() {
    playerBlocks = TacticalBlockGenerator.generateBlocksForGrid(
      gridSize: gridSize,
      gridOccupancy: getGridOccupancy(),
      score: scoreManager.currentScore,
      currentLevel: levelManager.currentLevel,
    );

    usedBlocks = List.generate(playerBlocks.length, (_) => false);

    if (!_anyBlockPlayable()) _generateEmergencyBlocks();
    if (!_anyBlockPlayable()) isGameOver = true;
  }

  void _generateEmergencyBlocks() {
    playerBlocks = [
      BlockShape(occupiedCells: [Vector2(0, 0)], color: Color(0xFFF44336)),
      BlockShape(occupiedCells: [Vector2(0, 0), Vector2(1, 0)], color: Color(0xFF2196F3)),
      BlockShape(occupiedCells: [Vector2(0, 0)], color: Color(0xFF4CAF50)),
    ];
    usedBlocks = [false, false, false];
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

    if (usedBlocks.every((e) => e)) generatePlayerBlocks();
    if (!_anyBlockPlayable()) isGameOver = true;

    return true;
  }

  void _checkCompletedLines() {
    final rows = <int>[];
    final cols = <int>[];

    for (int y = 0; y < gridSize; y++) {
      if (grid[y].every((c) => c.occupied)) rows.add(y);
    }
    for (int x = 0; x < gridSize; x++) {
      if (List.generate(gridSize, (y) => grid[y][x]).every((c) => c.occupied)) cols.add(x);
    }

    for (final r in rows) for (int x = 0; x < gridSize; x++) grid[r][x].clear();
    for (final c in cols) for (int y = 0; y < gridSize; y++) grid[y][c].clear();

    final cleared = rows.length + cols.length;
    if (cleared > 0) scoreManager.addScore(cleared * gridSize * 5);
  }

  bool _anyBlockPlayable() {
    for (int i = 0; i < playerBlocks.length; i++) {
      if (!usedBlocks[i] && blockFitsAnywhere(playerBlocks[i])) return true;
    }
    return false;
  }

  // ✅ دوال إضافية
  List<int> getClearedLines() {
    final cleared = <int>[];
    for (int y = 0; y < gridSize; y++) {
      if (grid[y].every((c) => c.occupied)) cleared.add(y);
    }
    return cleared;
  }
}
