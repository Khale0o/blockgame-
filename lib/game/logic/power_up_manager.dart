import 'package:blickgame/game/logic/game_manager.dart';

import 'block_model.dart';

class PowerUpManager {
  void applyPowerUp(PowerUpType type, List<List<Cell>> grid, int row, int col) {
    switch (type) {
      case PowerUpType.bomb:
        _applyBomb(grid, row, col);
        break;
      case PowerUpType.lineClear:
        _applyLineClear(grid, row, col);
        break;
      case PowerUpType.swap:
        // Handled elsewhere in the game flow
        break;
      case PowerUpType.hint:
        // Handled by hint system
        break;
      case PowerUpType.none:
        break;
    }
  }
  
  void _applyBomb(List<List<Cell>> grid, int centerRow, int centerCol) {
    for (int y = centerRow - 1; y <= centerRow + 1; y++) {
      for (int x = centerCol - 1; x <= centerCol + 1; x++) {
        if (y >= 0 && y < grid.length && x >= 0 && x < grid[0].length) {
          if (!grid[y][x].locked) {
            grid[y][x] = Cell(locked: grid[y][x].locked);
          }
        }
      }
    }
  }
  
  void _applyLineClear(List<List<Cell>> grid, int row, int col) {
    // Clear entire row
    for (int x = 0; x < grid[0].length; x++) {
      if (!grid[row][x].locked) {
        grid[row][x] = Cell(locked: grid[row][x].locked);
      }
    }
    
    // Clear entire column
    for (int y = 0; y < grid.length; y++) {
      if (!grid[y][col].locked) {
        grid[y][col] = Cell(locked: grid[y][col].locked);
      }
    }
  }
}