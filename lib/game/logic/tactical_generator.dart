// game/logic/tactical_generator.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'block_model.dart';

class TacticalBlockGenerator {
  static final Random _random = Random();
  
  // البلوكات الأساسية في Block Blast
  static final List<List<Vector2>> _blockPatterns = [
    // 1x1 (أحمر غالباً)
    [Vector2(0, 0)],
    
    // 2x1 (أزرق)
    [Vector2(0, 0), Vector2(1, 0)],
    
    // 1x2 (أخضر)
    [Vector2(0, 0), Vector2(0, 1)],
    
    // 2x2 (برتقالي)
    [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)],
    
    // 3x1 (بنفسجي)
    [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
    
    // L-shape 3x2 (سماوي)
    [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
    
    // T-shape 3x2 (أصفر)
    [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(1, 1)],
    
    // Z-shape 3x2 (وردي)
    [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)],
  ];
  
  // ألوان Block Blast الأصلية
  static final List<Color> _blockColors = [
    Color(0xFFF44336), // Red - 1x1
    Color(0xFF2196F3), // Blue - 2x1
    Color(0xFF4CAF50), // Green - 1x2
    Color(0xFFFF9800), // Orange - 2x2
    Color(0xFF9C27B0), // Purple - 3x1
    Color(0xFF00BCD4), // Cyan - L-shape
    Color(0xFFFFEB3B), // Yellow - T-shape
    Color(0xFFE91E63), // Pink - Z-shape
  ];
  
  static List<BlockShape> generateBlocksForGrid({
    required int gridSize,
    required List<List<bool>> gridOccupancy,
    required int score,
    required int currentLevel,
  }) {
    final analysis = _analyzeGrid(gridOccupancy);
    final playerMood = _calculatePlayerMood(analysis, score);
    
    // كتير شغال كويس - أعطيه بلوكات تساعدو
    if (playerMood == PlayerMood.doingGreat) {
      return _generateHelperBlocks(analysis, gridSize, gridOccupancy);
    }
    
    // عالق - ساعده يطلع
    if (playerMood == PlayerMood.stuck) {
      return _generateRescueBlocks(analysis, gridSize, gridOccupancy);
    }
    
    // طبيعي - خلي اللعبة ممتعة
    return _generateFunBlocks(analysis, gridSize, gridOccupancy, currentLevel);
  }
  
  static GridAnalysis _analyzeGrid(List<List<bool>> grid) {
    final size = grid.length;
    final analysis = GridAnalysis();
    
    // 1. تحليل الصفوف القريبة من الإكمال
    for (int y = 0; y < size; y++) {
      int emptyInRow = 0;
      for (int x = 0; x < size; x++) {
        if (!grid[y][x]) emptyInRow++;
      }
      if (emptyInRow <= 2 && emptyInRow > 0) {
        analysis.nearlyCompleteRows.add(NearlyCompleteLine(y, emptyInRow, true));
      }
    }
    
    // 2. تحليل الأعمدة القريبة من الإكمال
    for (int x = 0; x < size; x++) {
      int emptyInCol = 0;
      for (int y = 0; y < size; y++) {
        if (!grid[y][x]) emptyInCol++;
      }
      if (emptyInCol <= 2 && emptyInCol > 0) {
        analysis.nearlyCompleteCols.add(NearlyCompleteLine(x, emptyInCol, false));
      }
    }
    
    // 3. تحليل الفراغات الكبيرة
    analysis.biggestGap = _findBiggestGap(grid);
    
    return analysis;
  }
  
  static PlayerMood _calculatePlayerMood(GridAnalysis analysis, int score) {
    // إذا معظم الجريد مملوء
    bool isGridAlmostFull = analysis.nearlyCompleteRows.length > 2 || 
                           analysis.nearlyCompleteCols.length > 2;
    
    // إذا اللاعب عنده نقاط كتير بس الجريد مملوء
    if (score > 300 && isGridAlmostFull) {
      return PlayerMood.stuck;
    }
    
    // إذا في صفوف وأعمدة قريبة من الإكمال
    if (analysis.nearlyCompleteRows.isNotEmpty || 
        analysis.nearlyCompleteCols.isNotEmpty) {
      return PlayerMood.doingGreat;
    }
    
    return PlayerMood.normal;
  }
  
  static List<BlockShape> _generateHelperBlocks(
    GridAnalysis analysis,
    int gridSize,
    List<List<bool>> gridOccupancy,
  ) {
    final blocks = <BlockShape>[];
    
    // الأولوية: إكمال الصفوف والأعمدة
    if (analysis.nearlyCompleteRows.isNotEmpty) {
      final row = analysis.nearlyCompleteRows.first;
      blocks.add(_createBlockForLine(row, true, gridOccupancy));
      
      // أضف بلوك مساعد ثاني
      if (analysis.nearlyCompleteRows.length > 1) {
        final row2 = analysis.nearlyCompleteRows[1];
        blocks.add(_createBlockForLine(row2, true, gridOccupancy));
      }
    } else if (analysis.nearlyCompleteCols.isNotEmpty) {
      final col = analysis.nearlyCompleteCols.first;
      blocks.add(_createBlockForLine(col, false, gridOccupancy));
    }
    
    // إذا مش كفاية، أضف بلوك عادي
    while (blocks.length < 3) {
      blocks.add(_getRandomBlock());
    }
    
    // تأكد من أن البلوكات يمكن وضعها
    return _ensurePlayable(blocks, gridSize, gridOccupancy);
  }
  
  static List<BlockShape> _generateRescueBlocks(
    GridAnalysis analysis,
    int gridSize,
    List<List<bool>> gridOccupancy,
  ) {
    final blocks = <BlockShape>[];
    
    // 1. بلوك صغير لتسهيل الحركة
    blocks.add(BlockShape(
      occupiedCells: [Vector2(0, 0)],
      color: _blockColors[0], // أحمر
    ));
    
    // 2. بلوك يناسب أكبر فراغ
    if (analysis.biggestGap != null) {
      blocks.add(_createBlockForGap(analysis.biggestGap!));
    } else {
      blocks.add(_getRandomBlock());
    }
    
    // 3. بلوك عادي
    blocks.add(_getRandomBlock());
    
    return _ensurePlayable(blocks, gridSize, gridOccupancy);
  }
  
  static List<BlockShape> _generateFunBlocks(
    GridAnalysis analysis,
    int gridSize,
    List<List<bool>> gridOccupancy,
    int level,
  ) {
    final blocks = <BlockShape>[];
    
    // 1. بلوك عادي
    blocks.add(_getRandomBlock());
    
    // 2. بلوك يناسب المستوى
    blocks.add(_getLevelAppropriateBlock(level));
    
    // 3. بلوك يخلق فرص جديدة
    blocks.add(_createOpportunityBlock(gridOccupancy));
    
    return _ensurePlayable(blocks, gridSize, gridOccupancy);
  }
  
  static BlockShape _createBlockForLine(
    NearlyCompleteLine line,
    bool isRow,
    List<List<bool>> grid,
  ) {
    final size = grid.length;
    
    if (isRow) {
      // للصفوف: بلوك أفقى
      if (line.emptyCells == 1) {
        return BlockShape(
          occupiedCells: [Vector2(0, 0)],
          color: _blockColors[0], // أحمر
        );
      } else if (line.emptyCells == 2) {
        return BlockShape(
          occupiedCells: [Vector2(0, 0), Vector2(1, 0)],
          color: _blockColors[1], // أزرق
        );
      }
    } else {
      // للأعمدة: بلوك رأسي
      if (line.emptyCells == 1) {
        return BlockShape(
          occupiedCells: [Vector2(0, 0)],
          color: _blockColors[0], // أحمر
        );
      } else if (line.emptyCells == 2) {
        return BlockShape(
          occupiedCells: [Vector2(0, 0), Vector2(0, 1)],
          color: _blockColors[2], // أخضر
        );
      }
    }
    
    return _getRandomBlock();
  }
  
  static BlockShape _createBlockForGap(Gap gap) {
    // أنشئ بلوك يناسب الفراغ الموجود
    if (gap.width >= 2 && gap.height >= 2) {
      return BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0),
          Vector2(0, 1), Vector2(1, 1),
        ],
        color: _blockColors[3], // برتقالي
      );
    } else if (gap.width >= 3) {
      return BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
        color: _blockColors[4], // بنفسجي
      );
    } else if (gap.height >= 3) {
      return BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)],
        color: _blockColors[2], // أخضر
      );
    }
    
    return _getRandomBlock();
  }
  
  static BlockShape _getLevelAppropriateBlock(int level) {
    // المستويات الأولى: بلوكات بسيطة
    if (level <= 3) {
      return _random.nextDouble() < 0.7 
          ? _getSimpleBlock() 
          : _getMediumBlock();
    }
    
    // المستويات المتوسطة: مزيج
    if (level <= 6) {
      final patterns = [0, 1, 2, 3, 4]; // 1x1, 2x1, 1x2, 2x2, 3x1
      final index = patterns[_random.nextInt(patterns.length)];
      return BlockShape(
        occupiedCells: _blockPatterns[index],
        color: _blockColors[index],
      );
    }
    
    // المستويات المتقدمة: كل البلوكات
    final index = _random.nextInt(_blockPatterns.length);
    return BlockShape(
      occupiedCells: _blockPatterns[index],
      color: _blockColors[index],
    );
  }
  
  static BlockShape _createOpportunityBlock(List<List<bool>> grid) {
    // بلوك يخلق فرص لمسح صفوف/أعمدة
    final size = grid.length;
    
    // ابحث عن منطقة حيث بلوك 2x2 يعمل تأثير رائع
    for (int y = 0; y < size - 1; y++) {
      for (int x = 0; x < size - 1; x++) {
        if (!grid[y][x] && !grid[y][x+1] && 
            !grid[y+1][x] && !grid[y+1][x+1]) {
          return BlockShape(
            occupiedCells: [
              Vector2(0, 0), Vector2(1, 0),
              Vector2(0, 1), Vector2(1, 1),
            ],
            color: _blockColors[3], // برتقالي
          );
        }
      }
    }
    
    return _getRandomBlock();
  }
  
  static BlockShape _getSimpleBlock() {
    final simple = [0, 1, 2]; // 1x1, 2x1, 1x2
    final index = simple[_random.nextInt(simple.length)];
    return BlockShape(
      occupiedCells: _blockPatterns[index],
      color: _blockColors[index],
    );
  }
  
  static BlockShape _getMediumBlock() {
    final medium = [3, 4]; // 2x2, 3x1
    final index = medium[_random.nextInt(medium.length)];
    return BlockShape(
      occupiedCells: _blockPatterns[index],
      color: _blockColors[index],
    );
  }
  
  static BlockShape _getRandomBlock() {
    final index = _random.nextInt(_blockPatterns.length);
    return BlockShape(
      occupiedCells: _blockPatterns[index],
      color: _blockColors[index],
    );
  }
  
  static List<BlockShape> _ensurePlayable(
    List<BlockShape> blocks,
    int gridSize,
    List<List<bool>> gridOccupancy,
  ) {
    final playableBlocks = <BlockShape>[];
    
    for (final block in blocks) {
      if (_canBlockBePlaced(block, gridSize, gridOccupancy)) {
        playableBlocks.add(block);
      } else {
        // استبدل ببلوك أصغر
        playableBlocks.add(_getSimpleBlock());
      }
    }
    
    return playableBlocks;
  }
  
  static bool _canBlockBePlaced(
    BlockShape block,
    int gridSize,
    List<List<bool>> gridOccupancy,
  ) {
    for (int y = 0; y <= gridSize - block.height; y++) {
      for (int x = 0; x <= gridSize - block.width; x++) {
        if (_canPlaceAt(block, gridOccupancy, x, y)) {
          return true;
        }
      }
    }
    return false;
  }
  
  static bool _canPlaceAt(
    BlockShape block,
    List<List<bool>> gridOccupancy,
    int startX,
    int startY,
  ) {
    for (final cell in block.occupiedCells) {
      final x = startX + cell.xi;
      final y = startY + cell.yi;
      
      if (y >= gridOccupancy.length || 
          x >= gridOccupancy[0].length || 
          gridOccupancy[y][x]) {
        return false;
      }
    }
    return true;
  }
  
  static Gap? _findBiggestGap(List<List<bool>> grid) {
    final size = grid.length;
    Gap? biggestGap;
    
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (!grid[y][x]) {
          // تحقق من الفراغ الأفقى
          int width = 1;
          while (x + width < size && !grid[y][x + width]) {
            width++;
          }
          
          // تحقق من الفراغ الرأسى
          int height = 1;
          bool canExtend = true;
          while (y + height < size && canExtend) {
            for (int wx = x; wx < x + width; wx++) {
              if (grid[y + height][wx]) {
                canExtend = false;
                break;
              }
            }
            if (canExtend) height++;
          }
          
          final gap = Gap(x, y, width, height);
          if (biggestGap == null || gap.area > biggestGap.area) {
            biggestGap = gap;
          }
        }
      }
    }
    
    return biggestGap;
  }
}

// ================= MODELS =================

enum PlayerMood {
  normal,
  doingGreat,
  stuck,
}

class GridAnalysis {
  List<NearlyCompleteLine> nearlyCompleteRows = [];
  List<NearlyCompleteLine> nearlyCompleteCols = [];
  Gap? biggestGap;
}

class NearlyCompleteLine {
  final int index;
  final int emptyCells;
  final bool isRow;
  
  NearlyCompleteLine(this.index, this.emptyCells, this.isRow);
}

class Gap {
  final int x;
  final int y;
  final int width;
  final int height;
  
  Gap(this.x, this.y, this.width, this.height);
  
  int get area => width * height;
}