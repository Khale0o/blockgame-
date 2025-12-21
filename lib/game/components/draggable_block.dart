import 'package:blickgame/game/logic/block_model.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';


class DraggableBlock extends PositionComponent with DragCallbacks {
  final BlockShape block;
  final int index;
  final void Function(DraggableBlock component, Vector2 worldPos)? onDrop;
  final void Function(DraggableBlock block)? onDragStarted; // ✅ غيرنا الاسم
  final bool isUsed;

  bool _isDragging = false;
  late Vector2 _originalPosition;

  DraggableBlock({
    required this.block,
    required this.index,
    required Vector2 position,
    required Vector2 size,
    required this.isUsed,
    this.onDrop,
    this.onDragStarted, // ✅ غيرنا الاسم
    Vector2? originalPosition,
  }) : super(position: position, size: size) {
    _originalPosition = originalPosition ?? position.clone();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final cellWidth = size.x / block.width;
    final cellHeight = size.y / block.height;

    for (final cellOffset in block.occupiedCells) {
      final cellRect = Rect.fromLTWH(
        cellOffset.x * cellWidth,
        cellOffset.y * cellHeight,
        cellWidth - 2, // Padding
        cellHeight - 2,
      );

      final blockColor = isUsed ? block.color.withOpacity(0.3) : block.color;

      final paint = Paint()
        ..color = blockColor
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(isUsed ? 0.1 : 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(4.0)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(4.0)),
        borderPaint,
      );
    }

    if (isUsed) {
      final usedPaint = Paint()
        ..color = Colors.red.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final center = size / 2;
      const crossSize = 20.0;

      canvas.drawLine(
        Offset(center.x - crossSize, center.y - crossSize),
        Offset(center.x + crossSize, center.y + crossSize),
        usedPaint,
      );
      canvas.drawLine(
        Offset(center.x + crossSize, center.y - crossSize),
        Offset(center.x - crossSize, center.y + crossSize),
        usedPaint,
      );
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (isUsed) return;
    
    _isDragging = true;
    _originalPosition = position.clone();
    priority = 100;
    
    if (onDragStarted != null) { // ✅ غيرنا الاسم هنا
      onDragStarted!(this);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDragging && !isUsed) {
      position += event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragging = false;
    priority = 0;

    if (isUsed) return;

    if (onDrop != null) {
      onDrop!(this, position.clone());
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _isDragging = false;
    position = _originalPosition;
    priority = 0;
  }

  Vector2 get originalPosition => _originalPosition;
}