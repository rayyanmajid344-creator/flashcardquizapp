import 'package:flutter/material.dart';

/// Vertical candy stripes, like the top of a popcorn box.
/// Gaps are transparent, so whatever is behind shows through.
class StripeBand extends StatelessWidget {
  const StripeBand({
    super.key,
    required this.color,
    this.height = 14,
    this.stripes = 9,
  });

  final Color color;
  final double height;

  /// Use an odd number so both ends get a colored stripe.
  final int stripes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var i = 0; i < stripes; i++)
            Expanded(
              child: ColoredBox(color: i.isEven ? color : Colors.transparent),
            ),
        ],
      ),
    );
  }
}
