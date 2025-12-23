import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/game_manager.dart';
import '../../utils/constants.dart';

class GridComponent extends PositionComponent {
  final GameManager gameManager;

  GridComponent({
    required this.gameManager,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(
            GameConstants.cellSize * GameConstants.gridSize,
          ),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = GameConstants.gridLineColor
      ..style = PaintingStyle.stroke;

    for (int y = 0; y < gameManager.gridSize; y++) {
      for (int x = 0; x < gameManager.gridSize; x++) {
        final cell = gameManager.grid[y][x];

        paint.color = cell.locked
            ? GameConstants.lockedCellColor
            : cell.occupied
                ? cell.blockColor!
                : GameConstants.emptyCellColor;

        final rect = Rect.fromLTWH(
          x * GameConstants.cellSize,
          y * GameConstants.cellSize,
          GameConstants.cellSize - GameConstants.blockPadding,
          GameConstants.cellSize - GameConstants.blockPadding,
        );

        canvas.drawRect(rect, paint);
        canvas.drawRect(
          Rect.fromLTWH(
            x * GameConstants.cellSize,
            y * GameConstants.cellSize,
            GameConstants.cellSize,
            GameConstants.cellSize,
          ),
          borderPaint,
        );
      }
    }
  }
}
