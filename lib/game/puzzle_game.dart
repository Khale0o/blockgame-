import 'package:blickgame/game/components/game_over_component.dart';
import 'package:blickgame/game/logic/block_model.dart' hide Vector2;
import 'package:blickgame/game/logic/game_manager.dart';
import 'package:blickgame/utils/constants.dart';
import 'package:blickgame/utils/storage.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart' hide Vector2;
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

  late TextComponent scoreText;
  late TextComponent highScoreText;
  late TextComponent crownIcon;

  int _uiHighScore = 0;
  bool _highScoreAnimated = false;

  bool _gameOver = false;
  bool _gameWon = false;
  GameOverComponent? _gameOverComponent;

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await GameStorage.instance.init();
    _uiHighScore = await GameStorage.instance.getHighScore();

    gameManager = GameManager(
      scoreManager: ScoreManager(),
      levelManager: LevelManager(),
      powerUpManager: PowerUpManager(),
    );

    final gridPx = gameManager.gridSize * cellSize;
    gridPosition = Vector2((size.x - gridPx) / 2, size.y * 0.18);

    gridComponent = GridComponent(
      gameManager: gameManager,
      position: gridPosition,
    );

    add(gridComponent);
    _addHUD();
    _spawnBlocks();
    _checkGameState();
  }

  void _addHUD() {
    scoreText = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, gridPosition.y - 70),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800),
      ),
    );

    crownIcon = TextComponent(
      text: '👑',
      position: Vector2(20, 18),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 22)),
    );

    highScoreText = TextComponent(
      text: 'BEST $_uiHighScore',
      position: Vector2(54, 22),
      textRenderer: TextPaint(
        style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );

    addAll([scoreText, crownIcon, highScoreText]);
  }

  void _updateHUD() async {
    final currentScore = gameManager.scoreManager.currentScore;

    if (currentScore > _uiHighScore) {
      _uiHighScore = currentScore;
      await GameStorage.instance.saveHighScore(_uiHighScore);
      if (!_highScoreAnimated) {
        _highScoreAnimated = true;
        crownIcon.add(
          ScaleEffect.by(Vector2.all(0.4), EffectController(duration: 0.18, reverseDuration: 0.18, curve: Curves.easeOutBack)),
        );
      }
    }

    scoreText.text = currentScore.toString();
    highScoreText.text = 'BEST $_uiHighScore';
  }

  void _checkGameState() {
    if (_gameOver || _gameWon) return;

    bool allBlocksPlaced = gameManager.usedBlocks.every((b) => b);
    if (allBlocksPlaced) {
      _showGameOver(title: '🎉 LEVEL COMPLETE!', message: 'You placed all blocks perfectly!\nScore: ${gameManager.scoreManager.currentScore}', color: Colors.green);
      _gameWon = true;
      return;
    }

    bool hasValidMove = gameManager.playerBlocks.asMap().entries.any((entry) {
      final i = entry.key;
      final block = entry.value;
      if (gameManager.usedBlocks[i]) return false;
      return gameManager.blockFitsAnywhere(block);
    });

    if (!hasValidMove) {
      _showGameOver(title: '😢 GAME OVER', message: 'No valid moves left!\nFinal Score: ${gameManager.scoreManager.currentScore}', color: Colors.red);
      _gameOver = true;
    }
  }

  void _showGameOver({required String title, required String message, required Color color}) {
    _gameOverComponent?.removeFromParent();
    _gameOverComponent = GameOverComponent(title: title, message: message, color: color, onRestart: _restartGame, size: size);
    add(_gameOverComponent!);
  }

  void _restartGame() {
    _gameOver = false;
    _gameWon = false;
    _highScoreAnimated = false;

    _gameOverComponent?.removeFromParent();
    _gameOverComponent = null;

    for (final b in blockComponents) b.removeFromParent();
    blockComponents.clear();

    gameManager = GameManager(scoreManager: ScoreManager(), levelManager: LevelManager(), powerUpManager: PowerUpManager());

    gridComponent.removeFromParent();
    gridComponent = GridComponent(gameManager: gameManager, position: gridPosition);
    add(gridComponent);

    _spawnBlocks();
    _updateHUD();
  }

  void _spawnBlocks() {
    final availableBlocks = gameManager.usedBlocks.asMap().entries.where((e) => !e.value).map((e) => e.key).toList();
    if (availableBlocks.isEmpty) return;

    for (final b in blockComponents) b.removeFromParent();
    blockComponents.clear();

    final spacing = size.x / 3;

    for (int i = 0; i < availableBlocks.length; i++) {
      final idx = availableBlocks[i];
      final block = gameManager.playerBlocks[idx];
      final blockSize = Vector2(block.width * cellSize, block.height * cellSize);

      final start = Vector2(spacing * i + spacing / 2 - blockSize.x / 2, size.y + 150);
      final target = Vector2(spacing * i + spacing / 2 - blockSize.x / 2, size.y * 0.78);

      final comp = DraggableBlock(block: block, index: idx, position: start, size: blockSize, isUsed: false, homePosition: target, onDrop: _onBlockDropped);

      comp.add(MoveEffect.to(target, EffectController(duration: 0.35, curve: Curves.easeOutBack)));

      add(comp);
      blockComponents.add(comp);
    }

    _updateHUD();
    _checkGameState();
  }

  void _onBlockDropped(DraggableBlock block, Vector2 worldPos) {
    if (_gameOver || _gameWon) return;

    final shape = block.block;
    final center = worldPos + block.size / 2;

    final gx = ((center.x - gridPosition.x) / cellSize - shape.width / 2).round();
    final gy = ((center.y - gridPosition.y) / cellSize - shape.height / 2).round();

    final x = gx.clamp(0, gameManager.gridSize - shape.width);
    final y = gy.clamp(0, gameManager.gridSize - shape.height);

    if (!gameManager.canPlaceBlock(shape, y, x) || !gameManager.placeBlock(block.index, y, x)) {
      block.returnToOriginal();
      return;
    }

    final snap = Vector2(gridPosition.x + x * cellSize, gridPosition.y + y * cellSize);

    block.add(MoveEffect.to(snap, EffectController(duration: 0.15)));
    block.add(ScaleEffect.by(Vector2.all(0.15), EffectController(duration: 0.08, reverseDuration: 0.08)));

    Future.delayed(const Duration(milliseconds: 180), () {
      if (!_gameOver && !_gameWon) _spawnBlocks();
    });
  }
}