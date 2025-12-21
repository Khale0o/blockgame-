import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/game_manager.dart';
import '../../utils/constants.dart';

class GridComponent extends PositionComponent {
  final GameManager gameManager;
  final double cellSize;
  
  GridComponent({
    required this.gameManager,
    required this.cellSize,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(cellSize * gameManager.gridSize));
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final gridPaint = Paint()
      ..color = GameConstants.gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw cells
    for (int y = 0; y < gameManager.gridSize; y++) {
      for (int x = 0; x < gameManager.gridSize; x++) {
        final cell = gameManager.grid[y][x];
        final cellRect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize - GameConstants.blockPadding,
          cellSize - GameConstants.blockPadding,
        );
        
        // Determine cell color
        if (cell.locked) {
          paint.color = GameConstants.lockedCellColor;
        } else if (cell.occupied) {
          paint.color = cell.blockColor ?? GameConstants.occupiedCellColor;
        } else {
          paint.color = GameConstants.emptyCellColor;
        }
        
        // Draw cell
        canvas.drawRect(cellRect, paint);
        
        // Draw grid lines
        canvas.drawRect(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
          gridPaint,
        );
      }
    }
  }
}