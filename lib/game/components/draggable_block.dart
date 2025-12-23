import 'dart:ui';
import 'package:blickgame/game/logic/block_model.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class DraggableBlock extends PositionComponent with DragCallbacks {
  final BlockShape block;
  final int index;
  final bool isUsed;
  final Vector2 homePosition; // ✅ أضف هذا

  final void Function(DraggableBlock block, Vector2 worldPos)? onDrop;

  bool _dragging = false;
  late Vector2 _originalPosition;

  double _scale = 1.0;
  double _glow = 0.0;

  DraggableBlock({
    required this.block,
    required this.index,
    required Vector2 position,
    required Vector2 size,
    required this.isUsed,
    required this.homePosition, // ✅ أضف هذا
    this.onDrop,
  }) : super(position: position, size: size) {
    _originalPosition = position.clone();
  }

  Vector2 get originalPosition => _originalPosition;

  @override
  void onMount() {
    super.onMount();
    _originalPosition = homePosition.clone(); // ✅ استخدم homePosition
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scale += ((_dragging ? 1.1 : 1.0) - _scale) * 10 * dt;
    _glow += ((_dragging ? 1.0 : 0.0) - _glow) * 10 * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(_scale);
    canvas.translate(-size.x / 2, -size.y / 2);

    final cellW = size.x / block.width;
    final cellH = size.y / block.height;

    for (final cell in block.occupiedCells) {
      final rect = Rect.fromLTWH(
        cell.x * cellW,
        cell.y * cellH,
        cellW - 2,
        cellH - 2,
      );

      if (_glow > 0) {
        final glowPaint = Paint()
          ..color = block.color.withOpacity(0.4 * _glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          glowPaint,
        );
      }

      final fill = Paint()..color = block.color;
      final border = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        border,
      );
    }

    canvas.restore();
  }

  @override
@override
void onDragStart(DragStartEvent event) {
  if (isUsed) return;
  _dragging = true;
  priority = 100;
}

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_dragging || isUsed) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragging = false;
    priority = 0;
    if (isUsed) return;
    // ✅ أرسل موقع البلوك (الزاوية العلوية اليسرى)
    onDrop?.call(this, position.clone());
  }

  void returnToOriginal() {
    // ✅ العودة لـ homePosition مباشرة
    children.whereType<MoveEffect>().forEach((effect) {
      effect.removeFromParent();
    });
    
    add(
      MoveEffect.to(
        homePosition,
        EffectController(
          duration: 0.25,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  void shakeBack() {
    children.whereType<MoveEffect>().forEach((effect) {
      effect.removeFromParent();
    });
    
    add(
      MoveEffect.by(
        Vector2(12, 0),
        EffectController(duration: 0.05, alternate: true, repeatCount: 4),
      ),
    );

    add(
      MoveEffect.to(
        homePosition,
        EffectController(duration: 0.35, curve: Curves.easeOutBack),
      ),
    );
  }
}