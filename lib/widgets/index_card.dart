import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'stripe_band.dart';

/// A popcorn-box style card: cream body with candy stripes along the top
/// and a chocolate label pill.
class IndexCard extends StatelessWidget {
  const IndexCard({
    super.key,
    required this.label,
    required this.text,
    required this.accent,
  });

  final String label;
  final String text;
  final Color accent;

  /// Very light deck colors would disappear on the cream card,
  /// so darken them a little for the stripes.
  Color get _stripeColor => accent.computeLuminance() > 0.6
      ? Color.lerp(accent, AppColors.ink, 0.3)!
      : accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            StripeBand(color: _stripeColor, height: 40, stripes: 9),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: displayStyle(
                            15,
                            color: AppColors.paper,
                            height: 1.2,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
