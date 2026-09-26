import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A one-time burst of confetti. Drawn by hand, no packages needed.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _seconds = 3.0;

  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _pieces = List.generate(90, (_) {
      return _Piece(
        // Mostly upward, spread about ±100°.
        angle: -pi / 2 + (random.nextDouble() - 0.5) * pi * 1.15,
        speed: 350 + random.nextDouble() * 550,
        size: 6 + random.nextDouble() * 7,
        spin: (random.nextDouble() - 0.5) * 14,
        color:
            AppColors.deckPalette[random.nextInt(AppColors.deckPalette.length)],
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_seconds * 1000).round()),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            _pieces,
            _controller.value * _seconds,
            _seconds,
          ),
        ),
      ),
    );
  }
}

class _Piece {
  _Piece({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t, this.duration);

  final List<_Piece> pieces;
  final double t; // seconds since start
  final double duration;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.35);
    final opacity = (1 - t / duration).clamp(0.0, 1.0).toDouble();

    for (final p in pieces) {
      // Slows down like air resistance, then gravity pulls it down.
      final distance = p.speed * (1 - exp(-2.5 * t)) / 2.5;
      final position =
          origin +
          Offset(
            cos(p.angle) * distance,
            sin(p.angle) * distance + 140 * t * t,
          );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(p.spin * t);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.55,
        ),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
