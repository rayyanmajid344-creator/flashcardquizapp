import 'package:flutter/material.dart';

import 'data/deck_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Needed before using plugins like shared_preferences.
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved decks before showing the app.
  await deckStore.load();

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
      home: const HomeScreen(),
    );
  }
}
