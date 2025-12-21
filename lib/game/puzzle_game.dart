import 'package:blickgame/game/logic/block_model.dart';
import 'package:blickgame/game/logic/game_manager.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'components/grid_component.dart';
import 'components/draggable_block.dart';

class PuzzleGame extends FlameGame with DragCallbacks, TapCallbacks {
  late GameManager gameManager;

  late GridComponent gridComponent;
  final List<DraggableBlock> blockComponents = [];

  final double cellSize = 40;
  Vector2 gridPosition = Vector2.zero();

  bool isAnimating = false;
  
  // ✅ جديدة: البلوك المحمول حاليًا
  DraggableBlock? currentDraggingBlock;
  Vector2? originalBlockPosition;

  late TextComponent scoreText;
  late TextComponent levelText;
  late TextComponent blocksText;

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

    final gridSizePx = gameManager.gridSize * cellSize;

    gridPosition = Vector2(
      (size.x - gridSizePx) / 2,
      size.y * 0.12,
    );

    gridComponent = GridComponent(
      gameManager: gameManager,
      cellSize: cellSize,
      position: gridPosition,
    );

    add(gridComponent);

    _spawnBlocks();
    _addHUD();
  }

  // =========================
  // BLOCK SPAWN
  // =========================

  void _spawnBlocks() {
    for (final b in blockComponents) {
      remove(b);
    }
    blockComponents.clear();

    final spacing = size.x / 3;

    for (int i = 0; i < gameManager.playerBlocks.length; i++) {
      final block = gameManager.playerBlocks[i];

      final blockSize = Vector2(
        block.width * cellSize,
        block.height * cellSize,
      );

      // ✅ جديدة: البلوكات تظهر من تحت الشاشة وتطلع
      final position = Vector2(
        spacing * i + spacing / 2 - blockSize.x / 2,
        size.y + 100, // تبدأ من تحت الشاشة
      );

      final targetPosition = Vector2(
        spacing * i + spacing / 2 - blockSize.x / 2,
        size.y * 0.78, // المكان النهائي
      );

final component = DraggableBlock(
  block: block,
  index: i,
  size: blockSize,
  position: position,
  isUsed: gameManager.isBlockUsed(i),
  onDrop: _onBlockDropped,
  onDragStarted: _onBlockDragStart, // ✅ غيرنا الاسم هنا
  originalPosition: targetPosition.clone(),
);

      // ✅ أنيميشن ظهور البلوك من تحت
      component.add(
        MoveEffect.to(
          targetPosition,
          EffectController(
            duration: 0.5,
            curve: Curves.easeOutBack,
          ),
        ),
      );

      add(component);
      blockComponents.add(component);
    }
  }

  // =========================
  // DRAG LOGIC
  // =========================

  void _onBlockDragStart(DraggableBlock block) {
    // ✅ نحفظ البلوك الحالي
    currentDraggingBlock = block;
    originalBlockPosition = block.position.clone();
    
    // ✅ البلوك ينفصل ويرتفع شوية
    block.add(
      MoveEffect.by(
        Vector2(0, -20),
        EffectController(
          duration: 0.1,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void _onBlockDropped(DraggableBlock component, Vector2 worldPos) {
    if (isAnimating) return;

    final BlockShape block = component.block;

    // ✅ إلغاء حفظ البلوك الحالي
    currentDraggingBlock = null;

    // ✅ الحساب من المركز
    final blockCenter = Vector2(
      worldPos.x + component.size.x / 2,
      worldPos.y + component.size.y / 2,
    );
    
    final centerGridX = (blockCenter.x - gridPosition.x) / cellSize;
    final centerGridY = (blockCenter.y - gridPosition.y) / cellSize;
    
    final topLeftGridX = centerGridX - (block.width / 2);
    final topLeftGridY = centerGridY - (block.height / 2);
    
    final gridX = topLeftGridX.round();
    final gridY = topLeftGridY.round();
    
    final clampedGridX = gridX.clamp(0, gameManager.gridSize - block.width);
    final clampedGridY = gridY.clamp(0, gameManager.gridSize - block.height);

    print('🎯 Placement Debug:');
    print('  Block center: ($centerGridX, $centerGridY)');
    print('  Top-left grid: ($topLeftGridX, $topLeftGridY)');
    print('  Rounded to: ($gridX, $gridY)');
    print('  Clamped to: ($clampedGridY, $clampedGridX)');
    print('  Block size: ${block.width}x${block.height}');

    // ✅ Check if block is used
    if (gameManager.isBlockUsed(component.index)) {
      print('❌ Block already used!');
      _returnBlockToOriginal(component);
      return;
    }

    if (!gameManager.canPlaceBlock(block, clampedGridY, clampedGridX)) {
      print('❌ Cannot place here!');
      _returnBlockToOriginal(component);
      return;
    }

    final result = gameManager.placeBlock(
      component.index,
      clampedGridY,
      clampedGridX,
    );

    if (!result.success) {
      print('❌ GameManager rejected placement');
      _returnBlockToOriginal(component);
      return;
    }

    print('✅ Placement successful!');
    
    // ✅ أنيميشن وضع البلوك في المكان
    final snappedPosition = Vector2(
      gridPosition.x + clampedGridX * cellSize,
      gridPosition.y + clampedGridY * cellSize,
    );
    
    component.add(
      MoveEffect.to(
        snappedPosition,
        EffectController(
          duration: 0.2,
          curve: Curves.easeOut,
        ),
      ),
    );
    
    // ✅ تأثير بسيط عند وضع البلوك
    _addPlacementEffect(clampedGridX, clampedGridY, block);

    // ✅ تأخير حذف البلوك بعد الأنيميشن
    Future.delayed(const Duration(milliseconds: 200), () {
      component.removeFromParent();
      _spawnBlocks();
      _updateHUD();

      // ✅ إذا فيه خطوط اتمسحت، نلعب أنيميشن السقوط
      if (result.clearedLines != null && result.clearedLines!.linesCleared > 0) {
        _playLineClearAnimation(result.clearedLines!);
      }

      if (result.needsNewBlocks) {
        _showMessage("New blocks!");
      }

      if (gameManager.isGameOver) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _showGameOver();
        });
      }
    });
  }

  // ✅ جديدة: أنيميشن سقوط الصفوف
  void _playLineClearAnimation(ClearedLines cleared) {
    isAnimating = true;
    
    // 1. أولاً نلمع الخطوط الممسوحة
    final highlightEffects = <Component>[];
    
    for (final row in cleared.clearedRows) {
      for (int x = 0; x < gameManager.gridSize; x++) {
        final effect = _createHighlightEffect(row, x, Colors.yellow);
        add(effect);
        highlightEffects.add(effect);
      }
    }
    
    for (final col in cleared.clearedCols) {
      for (int y = 0; y < gameManager.gridSize; y++) {
        final effect = _createHighlightEffect(y, col, Colors.yellow);
        add(effect);
        highlightEffects.add(effect);
      }
    }
    
    // 2. بعد تلميع، نبدأ أنيميشن السقوط
    Future.delayed(const Duration(milliseconds: 300), () {
      // نحذف التلميع
      for (final effect in highlightEffects) {
        remove(effect);
      }
      
      // نلعب أنيميشن السقوط
      final fallingEffects = <Component>[];
      
      for (final row in cleared.clearedRows) {
        for (int x = 0; x < gameManager.gridSize; x++) {
          if (gameManager.grid[row][x].occupied) {
            final effect = _createFallingEffect(row, x);
            add(effect);
            fallingEffects.add(effect);
          }
        }
      }
      
      for (final col in cleared.clearedCols) {
        for (int y = 0; y < gameManager.gridSize; y++) {
          if (gameManager.grid[y][col].occupied) {
            final effect = _createFallingEffect(y, col);
            add(effect);
            fallingEffects.add(effect);
          }
        }
      }
      
      // 3. بعد الأنيميشن، نمسح الخطوط ونكمل
      Future.delayed(const Duration(milliseconds: 800), () {
        // نحذف أنيميشن السقوط
        for (final effect in fallingEffects) {
          remove(effect);
        }
        
        // نطبق المسح الفعلي
        gameManager.applyLineClear(cleared);
        
        // نحدث الـ HUD
        _updateHUD();
        
        isAnimating = false;
      });
    });
  }

  RectangleComponent _createHighlightEffect(int row, int col, Color color) {
    return RectangleComponent(
      size: Vector2.all(cellSize - 4),
      position: Vector2(
        gridPosition.x + col * cellSize + 2,
        gridPosition.y + row * cellSize + 2,
      ),
      paint: Paint()..color = color.withOpacity(0.7),
    );
  }

  PositionComponent _createFallingEffect(int row, int col) {
    final cell = gameManager.grid[row][col];
    
    final particle = RectangleComponent(
      size: Vector2(cellSize - 4, cellSize - 4),
      position: Vector2(
        gridPosition.x + col * cellSize + 2,
        gridPosition.y + row * cellSize + 2,
      ),
      paint: Paint()..color = cell.blockColor ?? Colors.white,
    );
    
    // أنيميشن سقوط مع دوران
    particle.add(
      MoveEffect.by(
        Vector2(0, 300),
        EffectController(
          duration: 0.8,
          curve: Curves.easeIn,
        ),
      ),
    );
    
    particle.add(
      OpacityEffect.to(
        0.0,
        EffectController(
          duration: 0.8,
        ),
      ),
    );
    
    particle.add(
      RotateEffect.by(
        2 * 3.14159, // دورة كاملة
        EffectController(
          duration: 0.8,
        ),
      ),
    );
    
    return particle;
  }

  void _addPlacementEffect(int gridX, int gridY, BlockShape block) {
    for (final cellOffset in block.occupiedCells) {
      final cellX = gridX + cellOffset.x;
      final cellY = gridY + cellOffset.y;
      
      final effect = CircleComponent(
        radius: cellSize / 3,
        position: Vector2(
          gridPosition.x + cellX * cellSize + cellSize / 2,
          gridPosition.y + cellY * cellSize + cellSize / 2,
        ),
        paint: Paint()..color = block.color.withOpacity(0.7),
      );
      
      effect.add(
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(
            duration: 0.3,
            reverseDuration: 0.1,
          ),
        )..onComplete = () {
          remove(effect);
        },
      );
      
      add(effect);
    }
  }

  void _returnBlockToOriginal(DraggableBlock block) {
    block.add(
      MoveEffect.to(
        block.originalPosition,
        EffectController(
          duration: 0.3,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  // =========================
  // HUD
  // =========================

  void _addHUD() {
    scoreText = TextComponent(
      text: 'Score: 0',
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
      text: 'Level: 1',
      position: Vector2(size.x - 130, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 20,
        ),
      ),
    );
    
    blocksText = TextComponent(
      text: 'Blocks: 3',
      position: Vector2(size.x / 2 - 50, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 20,
        ),
      ),
    );

    add(scoreText);
    add(levelText);
    add(blocksText);
  }

  void _updateHUD() {
    scoreText.text = 'Score: ${gameManager.scoreManager.currentScore}';
    levelText.text = 'Level: ${gameManager.levelManager.currentLevel}';
    
    final blocksLeft = 3 - gameManager.blocksPlaced;
    blocksText.text = 'Blocks: $blocksLeft';
  }

  void _showMessage(String message) {
    final messageText = TextComponent(
      text: message,
      position: Vector2(size.x / 2, size.y * 0.4),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 4,
            )
          ],
        ),
      ),
    );

    add(messageText);

    Future.delayed(const Duration(seconds: 2), () {
      if (messageText.isMounted) {
        remove(messageText);
      }
    });
  }

  // =========================
  // GAME OVER
  // =========================

  void _showGameOver() {
    final overlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.75),
    );

    final gameOverText = TextComponent(
      text: 'GAME OVER',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 42,
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final finalScoreText = TextComponent(
      text: 'Score: ${gameManager.scoreManager.currentScore}',
      anchor: Anchor.center,
      position: size / 2 + Vector2(0, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.yellow,
        ),
      ),
    );

    final button = RectangleComponent(
      size: Vector2(200, 60),
      position: size / 2 + Vector2(-100, 120),
      paint: Paint()..color = Colors.green,
    );

    final buttonText = TextComponent(
      text: 'PLAY AGAIN',
      position: size / 2 + Vector2(-60, 130),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(overlay);
    add(gameOverText);
    add(finalScoreText);
    add(button);
    add(buttonText);

    final tapArea = _GameOverButton(
      position: size / 2 + Vector2(-100, 120),
      size: Vector2(200, 60),
      onTap: () {
        resetGame();
        children.whereType<RectangleComponent>().forEach(remove);
        children.whereType<TextComponent>().forEach(remove);
        children.whereType<_GameOverButton>().forEach(remove);
      },
    );

    add(tapArea);
  }

  void resetGame() {
    gameManager.resetGame();
    _spawnBlocks();
    _updateHUD();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateHUD();
  }
}

class _GameOverButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  
  _GameOverButton({
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size);
  
  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}