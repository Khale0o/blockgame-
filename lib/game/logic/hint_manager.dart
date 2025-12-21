import 'dart:math';
import 'block_model.dart';
import 'game_manager.dart';

class HintManager {
  final GameManager gameManager;
  
  HintManager(this.gameManager);
  
  List<PlacementHint> getBestPlacements(BlockShape block) {
    final List<PlacementHint> hints = [];
    int bestScore = -1;
    
    for (int y = 0; y <= gameManager.gridSize - block.height; y++) {
      for (int x = 0; x <= gameManager.gridSize - block.width; x++) {
        if (gameManager.canPlaceBlock(block, y, x)) {
          // Simulate placement
          final simulatedScore = _simulatePlacement(block, y, x);
          hints.add(PlacementHint(x, y, simulatedScore));
          
          if (simulatedScore > bestScore) {
            bestScore = simulatedScore;
          }
        }
      }
    }
    
    // Sort by score descending
    hints.sort((a, b) => b.score.compareTo(a.score));
    
    return hints;
  }
  
  int _simulatePlacement(BlockShape block, int row, int col) {
    // Create a temporary copy of the grid
    final tempGrid = _copyGrid(gameManager.grid);
    
    // Place the block
    for (final cellOffset in block.occupiedCells) {
      final cellX = col + cellOffset.x.toInt();
      final cellY = row + cellOffset.y.toInt();
      tempGrid[cellY][cellX].occupied = true;
    }
    
    // Calculate potential lines cleared
    return _calculatePotentialLines(tempGrid);
  }
  
  List<List<Cell>> _copyGrid(List<List<Cell>> original) {
    return original.map((row) {
      return row.map((cell) {
        return Cell(
          occupied: cell.occupied,
          locked: cell.locked,
          powerUp: cell.powerUp,
          blockType: cell.blockType,
        );
      }).toList();
    }).toList();
  }
  
  int _calculatePotentialLines(List<List<Cell>> grid) {
    int potentialLines = 0;
    final gridSize = grid.length;
    
    // Check rows
    for (int y = 0; y < gridSize; y++) {
      bool rowComplete = true;
      for (int x = 0; x < gridSize; x++) {
        if (!grid[y][x].occupied && !grid[y][x].locked) {
          rowComplete = false;
          break;
        }
      }
      if (rowComplete) potentialLines++;
    }
    
    // Check columns
    for (int x = 0; x < gridSize; x++) {
      bool colComplete = true;
      for (int y = 0; y < gridSize; y++) {
        if (!grid[y][x].occupied && !grid[y][x].locked) {
          colComplete = false;
          break;
        }
      }
      if (colComplete) potentialLines++;
    }
    
    return potentialLines;
  }
}

class PlacementHint {
  final int x;
  final int y;
  final int score;
  
  PlacementHint(this.x, this.y, this.score);
}