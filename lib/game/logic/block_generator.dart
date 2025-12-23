// game/logic/block_generator.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'block_model.dart';

class BlockGenerator {
  static final Random _random = Random();
  
  static List<BlockShape> generateSmartBlocks({
    required int gridSize,
    required int currentLevel,
    required int numberOfBlocks,
    required List<List<bool>> gridOccupancy,
  }) {
    final blocks = <BlockShape>[];
    final difficulty = _calculateDifficulty(currentLevel);
    
    final emptySpaces = _countEmptySpaces(gridOccupancy);
    final gridFillRatio = 1 - (emptySpaces / (gridSize * gridSize));
    
    for (int i = 0; i < numberOfBlocks; i++) {
      final block = _generateSmartBlock(
        gridSize: gridSize,
        gridFillRatio: gridFillRatio,
        difficulty: difficulty,
        gridOccupancy: gridOccupancy,
      );
      blocks.add(block);
    }
    
    return _validateBlocks(blocks, gridSize, gridOccupancy);
  }
  
  static BlockShape _generateSmartBlock({
    required int gridSize,
    required double gridFillRatio,
    required double difficulty,
    required List<List<bool>> gridOccupancy,
  }) {
    double randomValue = _random.nextDouble();
    
    if (gridFillRatio > 0.8) {
      return _generateSmallBlock();
    }
    
    if (gridFillRatio > 0.5) {
      if (randomValue < 0.4) return _generateSmallBlock();
      if (randomValue < 0.7) return _generateMediumBlock();
      return _generateLargeBlock(difficulty);
    }
    
    if (randomValue < 0.3) return _generateSmallBlock();
    if (randomValue < 0.6) return _generateMediumBlock();
    return _generateLargeBlock(difficulty);
  }
  
  static BlockShape _generateSmallBlock() {
    final shapes = [
      BlockShape(
        occupiedCells: [Vector2(0, 0)],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(1, 0)],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(0, 1)],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)],
        color: _getRandomColor(),
      ),
    ];
    return shapes[_random.nextInt(shapes.length)];
  }
  
  static BlockShape _generateMediumBlock() {
    final shapes = [
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0),
          Vector2(0, 1), Vector2(1, 1),
        ],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
          Vector2(1, 1),
        ],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(0, 0),
          Vector2(0, 1),
          Vector2(1, 1),
          Vector2(2, 1),
        ],
        color: _getRandomColor(),
      ),
    ];
    return shapes[_random.nextInt(shapes.length)];
  }
  
  static BlockShape _generateLargeBlock(double difficulty) {
    final shapes = [
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0),
          Vector2(1, 1), Vector2(2, 1),
        ],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(1, 0),
          Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
          Vector2(1, 2),
        ],
        color: _getRandomColor(),
      ),
      BlockShape(
        occupiedCells: [
          Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
          Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
          Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
        ],
        color: _getRandomColor(),
      ),
    ];
    
    if (difficulty > 0.6) {
      return shapes[_random.nextInt(shapes.length)];
    }
    
    return _generateMediumBlock();
  }
  
  static List<BlockShape> _validateBlocks(
    List<BlockShape> blocks,
    int gridSize,
    List<List<bool>> gridOccupancy,
  ) {
    final validatedBlocks = <BlockShape>[];
    
    for (final block in blocks) {
      bool canPlace = _canBlockBePlaced(block, gridSize, gridOccupancy);
      
      if (canPlace) {
        validatedBlocks.add(block);
      } else {
        final alternative = _findAlternativeBlock(block, gridSize, gridOccupancy);
        validatedBlocks.add(alternative);
      }
    }
    
    return validatedBlocks;
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
  
  static BlockShape _findAlternativeBlock(
    BlockShape original,
    int gridSize,
    List<List<bool>> gridOccupancy,
  ) {
    final smallerBlocks = [
      BlockShape(
        occupiedCells: [Vector2(0, 0)],
        color: original.color,
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(1, 0)],
        color: original.color,
      ),
      BlockShape(
        occupiedCells: [Vector2(0, 0), Vector2(0, 1)],
        color: original.color,
      ),
    ];
    
    for (final block in smallerBlocks) {
      if (_canBlockBePlaced(block, gridSize, gridOccupancy)) {
        return block;
      }
    }
    
    return smallerBlocks.first;
  }
  
  static int _countEmptySpaces(List<List<bool>> gridOccupancy) {
    int empty = 0;
    for (final row in gridOccupancy) {
      for (final cell in row) {
        if (!cell) empty++;
      }
    }
    return empty;
  }
  
  static double _calculateDifficulty(int level) {
    if (level <= 3) return 0.2;
    if (level <= 6) return 0.4;
    if (level <= 9) return 0.6;
    return 0.8;
  }
  
  static Color _getRandomColor() {
    final colors = [
      Color(0xFFF44336),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
      Color(0xFFFFEB3B),
      Color(0xFFE91E63),
    ];
    return colors[_random.nextInt(colors.length)];
  }
}