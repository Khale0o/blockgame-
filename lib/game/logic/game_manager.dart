import 'dart:math';
import 'package:flutter/material.dart';

import 'block_model.dart';

/// =====================
/// CELL MODEL
/// =====================

class Cell {
  bool occupied;
  bool locked;
  BlockType? blockType;
  Color? blockColor;
  PowerUpType powerUp;

  Cell({
    this.occupied = false,
    this.locked = false,
    this.blockType,
    this.blockColor,
    this.powerUp = PowerUpType.none,
  });

  void clear() {
    occupied = false;
    blockType = null;
    blockColor = null;
    powerUp = PowerUpType.none;
  }
}

/// =====================
/// SCORE MANAGER
/// =====================

class ScoreManager {
  int currentScore = 0;
  int highScore = 0;

  void addScore(int value) {
    currentScore += value;
    if (currentScore > highScore) highScore = currentScore;
  }

  void reset() {
    currentScore = 0;
  }
}

/// =====================
/// LEVEL MANAGER
/// =====================

class LevelManager {
  int currentLevel = 1;

  void updateLevel(int score) => currentLevel = (score ~/ 500) + 1;

  double getLockedCellProbability() => (currentLevel - 1) * 0.03;

  void reset() => currentLevel = 1;
}

/// =====================
/// POWER UP MANAGER
/// =====================

class PowerUpManager {
  void apply(PowerUpType type, List<List<Cell>> grid, int row, int col) {
    // To be implemented
  }
}

/// =====================
/// GAME MANAGER
/// =====================

class GameManager {
  final int gridSize;
  late List<List<Cell>> grid;
  final Random random = Random();

  final ScoreManager scoreManager;
  final LevelManager levelManager;
  final PowerUpManager powerUpManager;

  List<BlockShape> playerBlocks = [];
  List<bool> usedBlocks = [false, false, false];
  int blocksPlaced = 0;

  bool isGameOver = false;
  
  // ✅ جديدة: أنيميشن سقوط الصفوف
  List<FallingAnimation> fallingAnimations = [];
  bool isClearingLines = false;

  GameManager({
    this.gridSize = 10,
    required this.scoreManager,
    required this.levelManager,
    required this.powerUpManager,
  }) {
    _initGrid();
    // ✅ بداية ببلوكات عشوائية موجودة
    _addRandomInitialBlocks();
    generatePlayerBlocks();
  }

  void _initGrid() {
    grid = List.generate(
      gridSize,
      (_) => List.generate(
        gridSize,
        (_) => Cell(
          locked: random.nextDouble() < levelManager.getLockedCellProbability(),
        ),
      ),
    );
  }
  
  // ✅ جديدة: إضافة بلوكات عشوائية في البداية
  void _addRandomInitialBlocks() {
    // نضيف 5-8 بلوك عشوائي في بداية اللعبة
    final initialBlockCount = random.nextInt(4) + 5; // 5-8 blocks
    
    for (int i = 0; i < initialBlockCount; i++) {
      BlockShape block;
      if (random.nextDouble() < 0.7) {
        block = BlockShape.randomSimple(random);
      } else {
        block = BlockShape.randomComplex(random);
      }
      
      // نحاول وضع البلوك في مكان عشوائي
      bool placed = false;
      for (int attempt = 0; attempt < 50 && !placed; attempt++) {
        final row = random.nextInt(gridSize - block.height + 1);
        final col = random.nextInt(gridSize - block.width + 1);
        
        if (canPlaceBlock(block, row, col)) {
          // نضع البلوك
          for (final p in block.occupiedCells) {
            final x = col + p.x;
            final y = row + p.y;
            final cell = grid[y][x];
            cell.occupied = true;
            cell.blockType = block.type;
            cell.blockColor = block.color;
          }
          placed = true;
        }
      }
    }
    
    print('✅ Added $initialBlockCount random blocks at game start');
  }

  bool canPlaceBlock(BlockShape block, int row, int col) {
    // Check bounds
    if (row < 0 || col < 0 || row + block.height > gridSize || col + block.width > gridSize) {
      return false;
    }
    
    // Check each cell
    for (final p in block.occupiedCells) {
      final x = col + p.x;
      final y = row + p.y;
      final cell = grid[y][x];
      if (cell.occupied || cell.locked) return false;
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
    playerBlocks.clear();
    usedBlocks = [false, false, false];
    blocksPlaced = 0;

    int attempts = 0;
    while (playerBlocks.length < 3 && attempts < 50) {
      final block = random.nextDouble() < 0.6
          ? BlockShape.randomSimple(random)
          : BlockShape.randomComplex(random);

      if (blockFitsAnywhere(block)) {
        playerBlocks.add(block);
      }
      attempts++;
    }

    if (playerBlocks.isEmpty) {
      isGameOver = true;
    }
  }

  PlaceResult placeBlock(int index, int row, int col) {
    if (index >= playerBlocks.length || usedBlocks[index]) {
      return PlaceResult.failure();
    }

    final block = playerBlocks[index];
    if (!canPlaceBlock(block, row, col)) {
      return PlaceResult.failure();
    }

    // Place the block
    for (final p in block.occupiedCells) {
      final x = col + p.x;
      final y = row + p.y;
      final cell = grid[y][x];
      cell.occupied = true;
      cell.blockType = block.type;
      cell.blockColor = block.color;
    }

    usedBlocks[index] = true;
    blocksPlaced++;

    // Clear completed lines (مع أنيميشن)
    final cleared = _checkCompletedLines();
    
    if (cleared.linesCleared > 0) {
      isClearingLines = true;
      // نبدأ أنيميشن السقوط قبل ما نمسح فعلياً
      _prepareFallingAnimations(cleared);
    } else {
      // إذا مفيش خطوط اتمسحت، نحسب النقاط كالعادي
      final score = _calculateScore(0, 1);
      scoreManager.addScore(score);
    }
    
    levelManager.updateLevel(scoreManager.currentScore);

    // Generate new blocks if all 3 are used
    bool needsNewBlocks = false;
    if (blocksPlaced >= 3) {
      generatePlayerBlocks();
      needsNewBlocks = true;
    }

    // Check game over
    if (!_anyBlockPlayable()) {
      isGameOver = true;
    }

    return PlaceResult.success(
      score: _calculateScore(cleared.linesCleared, cleared.comboMultiplier), 
      clearedLines: cleared,
      needsNewBlocks: needsNewBlocks,
    );
  }
  
  // ✅ جديدة: تحضير أنيميشن السقوط
  void _prepareFallingAnimations(ClearedLines cleared) {
    fallingAnimations.clear();
    
    // نجهز الأنيميشن للصفوف الممسوحة
    for (final row in cleared.clearedRows) {
      for (int x = 0; x < gridSize; x++) {
        final cell = grid[row][x];
        if (cell.occupied) {
          fallingAnimations.add(FallingAnimation(
            row: row,
            col: x,
            color: cell.blockColor ?? Colors.white,
          ));
        }
      }
    }
    
    // نجهز الأنيميشن للأعمدة الممسوحة
    for (final col in cleared.clearedCols) {
      for (int y = 0; y < gridSize; y++) {
        final cell = grid[y][col];
        if (cell.occupied) {
          fallingAnimations.add(FallingAnimation(
            row: y,
            col: col,
            color: cell.blockColor ?? Colors.white,
          ));
        }
      }
    }
  }
  
  // ✅ جديدة: تطبيق مسح الخطوط بعد الأنيميشن
  void applyLineClear(ClearedLines cleared) {
    // Clear rows
    for (final r in cleared.clearedRows) {
      for (int x = 0; x < gridSize; x++) {
        grid[r][x].clear();
      }
    }

    // Clear columns
    for (final c in cleared.clearedCols) {
      for (int y = 0; y < gridSize; y++) {
        grid[y][c].clear();
      }
    }
    
    // نحسب النقاط
    final score = _calculateScore(cleared.linesCleared, cleared.comboMultiplier);
    scoreManager.addScore(score);
    
    // ننتهي من الأنيميشن
    isClearingLines = false;
    fallingAnimations.clear();
  }

  ClearedLines _checkCompletedLines() {
    final rows = <int>{};
    final cols = <int>{};

    // Check rows
    for (int y = 0; y < gridSize; y++) {
      bool rowComplete = true;
      for (int x = 0; x < gridSize; x++) {
        final cell = grid[y][x];
        if (!cell.occupied || cell.locked) {
          rowComplete = false;
          break;
        }
      }
      if (rowComplete) rows.add(y);
    }

    // Check columns
    for (int x = 0; x < gridSize; x++) {
      bool colComplete = true;
      for (int y = 0; y < gridSize; y++) {
        final cell = grid[y][x];
        if (!cell.occupied || cell.locked) {
          colComplete = false;
          break;
        }
      }
      if (colComplete) cols.add(x);
    }

    final total = rows.length + cols.length;
    return ClearedLines(
      linesCleared: total,
      comboMultiplier: total > 1 ? total : 1,
      clearedRows: rows.toList(),
      clearedCols: cols.toList(),
    );
  }

  int _calculateScore(int lines, int combo) {
    if (lines == 0) return 0;
    return lines * gridSize * 10 * combo;
  }

  bool _anyBlockPlayable() {
    for (int i = 0; i < playerBlocks.length; i++) {
      if (!usedBlocks[i] && blockFitsAnywhere(playerBlocks[i])) {
        return true;
      }
    }
    return false;
  }

  bool isBlockUsed(int index) {
    return index < usedBlocks.length ? usedBlocks[index] : false;
  }

  void resetGame() {
    isGameOver = false;
    isClearingLines = false;
    fallingAnimations.clear();
    scoreManager.reset();
    levelManager.reset();
    _initGrid();
    _addRandomInitialBlocks();
    generatePlayerBlocks();
  }
}

// ✅ جديدة: كلاس للأنيميشن
class FallingAnimation {
  final int row;
  final int col;
  final Color color;
  
  FallingAnimation({
    required this.row,
    required this.col,
    required this.color,
  });
}

class PlaceResult {
  final bool success;
  final int score;
  final ClearedLines? clearedLines;
  final bool needsNewBlocks;

  PlaceResult({
    required this.success,
    this.score = 0,
    this.clearedLines,
    this.needsNewBlocks = false,
  });

  factory PlaceResult.success({
    int score = 0,
    ClearedLines? clearedLines,
    bool needsNewBlocks = false,
  }) {
    return PlaceResult(
      success: true,
      score: score,
      clearedLines: clearedLines,
      needsNewBlocks: needsNewBlocks,
    );
  }

  factory PlaceResult.failure() {
    return PlaceResult(success: false);
  }
}

class ClearedLines {
  final int linesCleared;
  final int comboMultiplier;
  final List<int> clearedRows;
  final List<int> clearedCols;

  ClearedLines({
    required this.linesCleared,
    required this.comboMultiplier,
    required this.clearedRows,
    required this.clearedCols,
  });
}