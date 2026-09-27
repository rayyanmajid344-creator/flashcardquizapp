import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/deck_store.dart';
import '../theme/app_theme.dart';
import '../widgets/stripe_band.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Animated popcorn box shown while the app loads saved decks and fonts.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _boxScale;
  late final Animation<double> _boxTilt;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // The box bounces in with a little wobble...
    _boxScale = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _boxTilt = Tween<double>(begin: -0.35, end: -0.06).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // ...then the title slides up.
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    _controller.forward();

    // Wait for the data, the fonts and a minimum display time, all at once.
    await Future.wait<void>([
      deckStore.load(),
      _loadFonts(),
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      fadeRoute(
        deckStore.hasOnboarded ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  /// Downloads the fonts during the splash so the next screen
  /// doesn't flash in a plain font first.
  Future<void> _loadFonts() async {
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.shrikhand(),
        GoogleFonts.dmSans(),
      ]).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Offline or slow network: carry on with fallback fonts.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: _boxTilt.value,
                child: Transform.scale(
                  scale: _boxScale.value,
                  child: const PopcornBox(),
                ),
              ),
              const SizedBox(height: 36),
              Opacity(
                opacity: _textFade.value,
                child: FractionalTranslation(
                  translation: _textSlide.value,
                  child: Column(
                    children: [
                      Text('Flashcard Quiz', style: displayStyle(40)),
                      const SizedBox(height: 8),
                      const Text(
                        'Study. Swipe. Score.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A striped popcorn box with popcorn peeking out of the top.
class PopcornBox extends StatelessWidget {
  const PopcornBox({super.key});

  static const _butter = Color(0xFFF8E3A8);

  // (left, top, size, color) for each piece of popcorn.
  static const _puffs = <(double, double, double, Color)>[
    (6.0, 24.0, 50.0, AppColors.paper),
    (46.0, 2.0, 60.0, _butter),
    (98.0, 12.0, 54.0, AppColors.paper),
    (128.0, 32.0, 40.0, _butter),
    (28.0, 38.0, 44.0, _butter),
    (76.0, 30.0, 48.0, AppColors.paper),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (left, top, size, color) in _puffs)
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 165,
            child: ClipPath(
              clipper: _BoxShapeClipper(),
              child: Stack(
                children: [
                  const ColoredBox(
                    color: AppColors.paper,
                    child: SizedBox.expand(),
                  ),
                  const StripeBand(
                    color: AppColors.cerulean,
                    height: 165,
                    stripes: 7,
                  ),
                  Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: AppColors.paper,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wider at the top than the bottom, like a real popcorn box.
class _BoxShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const inset = 18.0;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - inset, size.height)
      ..lineTo(inset, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
