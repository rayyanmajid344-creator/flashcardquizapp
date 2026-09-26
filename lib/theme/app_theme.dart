import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette: chocolate, popcorn and cerulean. Fonts: Shrikhand + DM Sans.
/// Chocolate is the room, popcorn is the paper and text, cerulean is the accent.
class AppColors {
  AppColors._();

  // Chocolate
  static const background = Color(0xFF2A1A12);
  static const surface = Color(0xFF3A261B);
  static const surfaceHigh = Color(0xFF4B3225);

  // Popcorn
  static const paper = Color(0xFFFFF3D6);
  static const paperRule = Color(0xFFBFE0F4); // faint cerulean writing lines
  static const ink = Color(0xFF2A1A12); // chocolate text on light colors

  static const textPrimary = Color(0xFFFFF3D6);
  static const textMuted = Color(0xFFBFA78F);

  // Cerulean
  static const cerulean = Color(0xFF2E9BDB);

  // Feedback colors, softened to sit with the palette.
  static const correct = Color(0xFF7CC99A); // pistachio
  static const wrong = Color(0xFFE5575B); // cherry

  /// Deck colors, all from the chocolate / popcorn / cerulean family.
  static const deckPalette = <Color>[
    Color(0xFF2E9BDB), // cerulean
    Color(0xFFF5CF63), // butter
    Color(0xFFD8955A), // caramel
    Color(0xFF8ACFF2), // sky
    Color(0xFFEBBE8C), // toffee
    Color(0xFFCFE9F8), // ice
  ];
}

/// The retro "cinema marquee" headline font (Shrikhand).
/// Shrikhand has a single weight, so never make it bold.
/// Body text everywhere else uses DM Sans (set in the theme below).
TextStyle displayStyle(
  double size, {
  Color color = AppColors.textPrimary,
  double height = 1.15,
}) => GoogleFonts.shrikhand(
  fontSize: size,
  color: color,
  height: height,
  fontWeight: FontWeight.w400,
);

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.cerulean,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.cerulean,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      );

  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: GoogleFonts.dmSans().fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: displayStyle(22),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cerulean, width: 2),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.cerulean,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.cerulean),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.paper,
      contentTextStyle: TextStyle(color: AppColors.ink),
      actionTextColor: AppColors.cerulean,
    ),
  );
}

/// Full-width filled button in a deck's color.
/// Use inside a Column or an Expanded (it stretches to fill the width).
ButtonStyle filledStyle(Color color) => FilledButton.styleFrom(
  backgroundColor: color,
  foregroundColor: AppColors.ink,
  minimumSize: const Size.fromHeight(54),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);

/// Full-width outlined button. Same layout rule as [filledStyle].
ButtonStyle outlinedStyle() => OutlinedButton.styleFrom(
  foregroundColor: AppColors.textPrimary,
  side: const BorderSide(color: Color(0x40FFF3D6)),
  minimumSize: const Size.fromHeight(54),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);
