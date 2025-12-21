// Create this new file: lib/game/components/tappable_area.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class TappableArea extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  
  TappableArea({
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size);
  
  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}