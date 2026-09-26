import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// "Card 3 of 7" plus an animated progress bar.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.index,
    required this.total,
    required this.color,
    required this.trailing,
  });

  final int index;
  final int total;
  final Color color;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : index / total;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Card ${index + 1} of $total',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
            const Spacer(),
            trailing,
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.white12,
            ),
          ),
        ),
      ],
    );
  }
}

/// A small flame counter that pops each time the streak changes.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final onFire = streak >= 3;

    return Center(
      child: Tooltip(
        message: 'Answers in a row',
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Container(
            key: ValueKey(streak),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: onFire
                  ? AppColors.deckPalette[1].withValues(alpha: 0.25)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: onFire
                      ? AppColors.deckPalette[1]
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
