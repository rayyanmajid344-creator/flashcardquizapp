import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Needed before using plugins like shared_preferences.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // The splash screen loads saved data, then moves on to
      // the welcome screen (first launch) or the home screen.
      home: const SplashScreen(),
    );
  }
}
