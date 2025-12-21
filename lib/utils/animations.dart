import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class GameAnimations {
  static const Curve placementCurve = Curves.easeOutBack;
  static const Curve lineClearCurve = Curves.easeInOutCubic;
  static const Curve levelTransitionCurve = Curves.easeInOutQuart;
  
  static TweenSequence<Color?> createCellColorTween(Color from, Color to) {
    return TweenSequence<Color?>(
      <TweenSequenceItem<Color?>>[
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: from, end: Colors.white),
          weight: 50,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: Colors.white, end: to),
          weight: 50,
        ),
      ],
    );
  }
}