import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/game_manager.dart';
import '../../utils/constants.dart';

class GridComponent extends PositionComponent {
  final GameManager gameManager;
  final Map<int, double> _rowFlash = {};
  final Map<int, double> _colFlash = {};

  GridComponent({required this.gameManager, required Vector2 position})
      : super(position: position, size: Vector2.all(GameConstants.cellSize * GameConstants.gridSize));

  @override
  void update(double dt) {
    super.update(dt);
    _rowFlash.updateAll((key, value) => value - dt * 3);
    _colFlash.updateAll((key, value) => value - dt * 3);
    _rowFlash.removeWhere((k, v) => v <= 0);
    _colFlash.removeWhere((k, v) => v <= 0);
    _detectClears();
  }

  void _detectClears() {
    final size = gameManager.gridSize;
    for (int y = 0; y < size; y++) {
      if (gameManager.grid[y].every((c) => c.occupied) && !_rowFlash.containsKey(y)) _rowFlash[y] = 1.0;
    }
    for (int x = 0; x < size; x++) {
      if (List.generate(size, (y) => gameManager.grid[y][x]).every((c) => c.occupied) && !_colFlash.containsKey(x)) _colFlash[x] = 1.0;
    }
  }

  Cell? getCell(int row, int col) {
    if (row < 0 || row >= gameManager.gridSize) return null;
    if (col < 0 || col >= gameManager.gridSize) return null;
    return gameManager.grid[row][col];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = GameConstants.gridLineColor..style = PaintingStyle.stroke;
    final glowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);

    for (int y = 0; y < gameManager.gridSize; y++) {
      for (int x = 0; x < gameManager.gridSize; x++) {
        final cell = gameManager.grid[y][x];
        Color baseColor = cell.locked
            ? GameConstants.lockedCellColor
            : cell.occupied
                ? cell.blockColor!
                : GameConstants.emptyCellColor;

        double flash = 0;
        if (_rowFlash.containsKey(y)) flash = _rowFlash[y]!;
        if (_colFlash.containsKey(x)) flash = flash > _colFlash[x]! ? flash : _colFlash[x]!;

        paint.color = Color.lerp(baseColor, Colors.white, flash.clamp(0, 1))!;

        final rect = Rect.fromLTWH(
          x * GameConstants.cellSize,
          y * GameConstants.cellSize,
          GameConstants.cellSize - GameConstants.blockPadding,
          GameConstants.cellSize - GameConstants.blockPadding,
        );

        if (flash > 0.05) {
          glowPaint.color = Colors.white.withOpacity(0.6 * flash.clamp(0, 1));
          canvas.drawRect(rect.inflate(3), glowPaint);
        }

        canvas.drawRect(rect, paint);
        canvas.drawRect(Rect.fromLTWH(x * GameConstants.cellSize, y * GameConstants.cellSize, GameConstants.cellSize, GameConstants.cellSize), borderPaint);
      }
    }
  }
}
