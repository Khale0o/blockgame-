// components/game_over_component.dart
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameOverComponent extends PositionComponent with TapCallbacks {
  final String title;
  final String message;
  final Color color;
  final VoidCallback onRestart;

  GameOverComponent({
    required this.title,
    required this.message,
    required this.color,
    required this.onRestart,
    required Vector2 size,
  }) : super(size: size);

  late TextComponent titleText;
  late TextComponent messageText;
  late TextComponent restartText;
  late RectangleComponent background;
  late RectangleComponent restartButton;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.85),
    );
    add(background);


    titleText = TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.35),
    );
    add(titleText);

    messageText = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.45),
    );
    add(messageText);

    restartButton = RectangleComponent(
      size: Vector2(200, 60),
      position: Vector2(size.x / 2 - 100, size.y * 0.65),
      paint: Paint()..color = color,
      anchor: Anchor.topLeft,
    )..add(
        ScaleEffect.by(
          Vector2.all(0.1),
          EffectController(
            duration: 0.5,
            reverseDuration: 0.5,
            infinite: true,
          ),
        ),
      );

    restartText = TextComponent(
      text: 'RESTART',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(restartButton.size.x / 2, restartButton.size.y / 2),
    );

    restartButton.add(restartText);
    add(restartButton);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final tapPosition = event.localPosition;
    final buttonRect = Rect.fromLTWH(
      size.x / 2 - 100,
      size.y * 0.65,
      200,
      60,
    );

    if (buttonRect.contains(Offset(tapPosition.x, tapPosition.y))) {
      onRestart();
    }
    super.onTapUp(event);
  }
}