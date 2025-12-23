import 'package:blickgame/game/components/game_over_component.dart';
import 'package:blickgame/game/logic/block_model.dart';
import 'package:blickgame/game/logic/game_manager.dart';
import 'package:blickgame/utils/constants.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'components/grid_component.dart';
import 'components/draggable_block.dart';

class PuzzleGame extends FlameGame with DragCallbacks, TapCallbacks {
  late GameManager gameManager;
  late GridComponent gridComponent;

  final List<DraggableBlock> blockComponents = [];

  final double cellSize = GameConstants.cellSize;
  Vector2 gridPosition = Vector2.zero();

  // HUD
  late TextComponent scoreText;
  late TextComponent levelText;
  
  // Game State
  bool _gameOver = false;
  bool _gameWon = false;
  GameOverComponent? _gameOverComponent;

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gameManager = GameManager(
      scoreManager: ScoreManager(),
      levelManager: LevelManager(),
      powerUpManager: PowerUpManager(),
    );

    final gridPx = gameManager.gridSize * cellSize;

    gridPosition = Vector2(
      (size.x - gridPx) / 2,
      size.y * 0.12,
    );

    gridComponent = GridComponent(
      gameManager: gameManager,
      position: gridPosition,
    );

    add(gridComponent);
    _addHUD();
    _spawnBlocks();
    
    // Check initial game state
    _checkGameState();
  }

  // ================= GAME STATE =================
  void _checkGameState() {
    if (_gameOver || _gameWon) return;

    // Check for WIN condition (all blocks placed successfully)
    bool allBlocksPlaced = true;
    for (int i = 0; i < gameManager.playerBlocks.length; i++) {
      if (!gameManager.usedBlocks[i]) {
        allBlocksPlaced = false;
        break;
      }
    }

    if (allBlocksPlaced) {
      _showGameOver(
        title: '🎉 LEVEL COMPLETE!',
        message: 'You placed all blocks perfectly!\nScore: ${gameManager.scoreManager.currentScore}',
        color: Colors.green,
      );
      _gameWon = true;
      return;
    }

    // Check for GAME OVER condition (no valid moves left)
    bool hasValidMove = false;
    for (int i = 0; i < gameManager.playerBlocks.length; i++) {
      if (gameManager.usedBlocks[i]) continue;
      
      final block = gameManager.playerBlocks[i];
      
      // Check if this block can be placed anywhere on the grid
      for (int y = 0; y <= gameManager.gridSize - block.height; y++) {
        for (int x = 0; x <= gameManager.gridSize - block.width; x++) {
          if (gameManager.canPlaceBlock(block, y, x)) {
            hasValidMove = true;
            break;
          }
        }
        if (hasValidMove) break;
      }
      if (hasValidMove) break;
    }

    if (!hasValidMove) {
      _showGameOver(
        title: '😢 GAME OVER',
        message: 'No valid moves left!\nFinal Score: ${gameManager.scoreManager.currentScore}',
        color: Colors.red,
      );
      _gameOver = true;
    }
  }

  void _showGameOver({
    required String title,
    required String message,
    required Color color,
  }) {
    if (_gameOverComponent != null) {
      _gameOverComponent!.removeFromParent();
    }

    _gameOverComponent = GameOverComponent(
      title: title,
      message: message,
      color: color,
      onRestart: _restartGame,
      size: size,
    );

    add(_gameOverComponent!);
  }

  void _restartGame() {
    // Reset game state
    _gameOver = false;
    _gameWon = false;
    
    if (_gameOverComponent != null) {
      _gameOverComponent!.removeFromParent();
      _gameOverComponent = null;
    }

    // Clear all blocks
    for (final block in blockComponents) {
      block.removeFromParent();
    }
    blockComponents.clear();

    // Reset game manager
    gameManager = GameManager(
      scoreManager: ScoreManager(),
      levelManager: LevelManager(),
      powerUpManager: PowerUpManager(),
    );

    // Reset grid
    gridComponent.removeFromParent();
    gridComponent = GridComponent(
      gameManager: gameManager,
      position: gridPosition,
    );
    add(gridComponent);

    // Start fresh
    _spawnBlocks();
    _updateHUD();
  }

  // ================= BLOCKS =================
  void _spawnBlocks() {
    for (final b in blockComponents) {
      b.removeFromParent();
    }
    blockComponents.clear();

    final spacing = size.x / 3;

    for (int i = 0; i < gameManager.playerBlocks.length; i++) {
      if (gameManager.usedBlocks[i]) continue;

      final block = gameManager.playerBlocks[i];

      final blockSize =
          Vector2(block.width * cellSize, block.height * cellSize);

      final start = Vector2(
        spacing * i + spacing / 2 - blockSize.x / 2,
        size.y + 120,
      );

      final target = Vector2(
        spacing * i + spacing / 2 - blockSize.x / 2,
        size.y * 0.78,
      );

      final comp = DraggableBlock(
        block: block,
        index: i,
        position: start,
        size: blockSize,
        isUsed: false,
        homePosition: target,
        onDrop: _onBlockDropped,
      );

      comp.add(
        MoveEffect.to(
          target,
          EffectController(duration: 0.35, curve: Curves.easeOutBack),
        ),
      );

      add(comp);
      blockComponents.add(comp);
    }

    _updateHUD();
    
    // Check game state after spawning blocks
    _checkGameState();
  }

  void _onBlockDropped(DraggableBlock block, Vector2 worldPos) {
    // Don't accept input if game is over
    if (_gameOver || _gameWon) return;
    
    final shape = block.block;
    final center = worldPos + block.size / 2;

    final gx =
        ((center.x - gridPosition.x) / cellSize - shape.width / 2).round();
    final gy =
        ((center.y - gridPosition.y) / cellSize - shape.height / 2).round();

    final x = gx.clamp(0, gameManager.gridSize - shape.width);
    final y = gy.clamp(0, gameManager.gridSize - shape.height);

    // ❌ Drop برّه أو مكان غلط
    if (!gameManager.canPlaceBlock(shape, y, x)) {
      block.returnToOriginal();
      return;
    }

    // ❌ فشل placement
    final placed = gameManager.placeBlock(block.index, y, x);
    if (!placed) {
      block.returnToOriginal();
      return;
    }

    // ✅ Placement صحيح
    final snap = Vector2(
      gridPosition.x + x * cellSize,
      gridPosition.y + y * cellSize,
    );

    block.add(
      MoveEffect.to(
        snap,
        EffectController(duration: 0.15),
      ),
    );

    block.add(
      ScaleEffect.by(
        Vector2.all(0.15),
        EffectController(duration: 0.08, reverseDuration: 0.08),
      ),
    );

    // ✅ اختفاء فقط بعد placement الصحيح
    Future.delayed(const Duration(milliseconds: 180), () {
      block.removeFromParent();
      _spawnBlocks(); // This will call _checkGameState
    });
  }

  // ================= HUD =================
  void _addHUD() {
    scoreText = TextComponent(
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    levelText = TextComponent(
      position: Vector2(size.x - 120, 20),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.cyan, fontSize: 20),
      ),
    );

    addAll([scoreText, levelText]);
  }

  void _updateHUD() {
    scoreText.text = 'Score: ${gameManager.scoreManager.currentScore}';
    levelText.text = 'Level: ${gameManager.levelManager.currentLevel}';
  }
}