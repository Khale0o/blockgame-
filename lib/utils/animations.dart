import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class GameAnimations {
  static const Curve placementCurve = Curves.easeOutBack;
  static const Curve lineClearCurve = Curves.easeInOutCubic;
  static const Curve levelTransitionCurve = Curves.easeInOutQuart;

  // Color flash لما الخط يتحذف
  static TweenSequence<Color?> createCellColorTween(
    Color from,
    Color to,
  ) {
    return TweenSequence<Color?>(
      <TweenSequenceItem<Color?>>[
        TweenSequenceItem(
          tween: ColorTween(begin: from, end: Colors.white),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.white, end: to),
          weight: 50,
        ),
      ],
    );
  }

  // Snap Scale
  static Animation<double> snapScale(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: placementCurve,
      ),
    );
  }

  // Pulse (High Score 👑)
  static Animation<double> pulse(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }
}
