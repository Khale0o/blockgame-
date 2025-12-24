import 'package:blickgame/game/logic/game_manager.dart';
import 'package:blickgame/game/logic/enums.dart';

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
        break;
      case PowerUpType.hint:
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
            grid[y][x].clear();
          }
        }
      }
    }
  }
  
  void _applyLineClear(List<List<Cell>> grid, int row, int col) {
    for (int x = 0; x < grid[0].length; x++) {
      if (!grid[row][x].locked) {
        grid[row][x].clear();
      }
    }
    
    for (int y = 0; y < grid.length; y++) {
      if (!grid[y][col].locked) {
        grid[y][col].clear();
      }
    }
  }
}