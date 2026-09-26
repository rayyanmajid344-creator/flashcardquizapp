import 'dart:math';

import 'package:flutter/material.dart';

/// Shows [front] or [back] with a 3D flip animation between them.
/// Give it a new key for each new card so it always starts face-up.
class FlipCard extends StatelessWidget {
  const FlipCard({
    super.key,
    required this.showBack,
    required this.front,
    required this.back,
  });

  final bool showBack;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: showBack ? pi : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutBack,
      builder: (context, angle, _) {
        final isBack = angle > pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // perspective
            ..rotateY(angle),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}
