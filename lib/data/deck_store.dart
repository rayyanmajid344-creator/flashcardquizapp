import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';
import 'sample_decks.dart';

/// Holds the decks and the user's name, tells the UI when something changes,
/// and saves everything to the device so it survives restarts.
///
/// Screens rebuild by wrapping themselves in a ListenableBuilder(listenable: deckStore).
class DeckStore extends ChangeNotifier {
  static const _decksKey = 'decks_v1';
  static const _nameKey = 'user_name';
  static const _onboardedKey = 'onboarded_v1';

  final List<Deck> _decks = [];
  SharedPreferences? _prefs;
  String? _userName;
  bool _hasOnboarded = false;

  List<Deck> get decks => List.unmodifiable(_decks);

  /// The name entered on the welcome screen, or null if none was given.
  String? get userName => _userName;

  /// False until the user has finished the welcome screen.
  bool get hasOnboarded => _hasOnboarded;

  int get totalCards =>
      _decks.fold<int>(0, (sum, deck) => sum + deck.cards.length);

  /// Called once by the splash screen when the app starts.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;

      final saved = prefs.getString(_decksKey);
      _userName = prefs.getString(_nameKey);
      // People who used the app before the welcome screen existed already
      // have decks saved, so they skip it.
      _hasOnboarded = prefs.getBool(_onboardedKey) ?? (saved != null);

      _decks.clear();
      if (saved != null) {
        final list = jsonDecode(saved) as List<dynamic>;
        _decks.addAll(
          list.map((json) => Deck.fromJson(json as Map<String, dynamic>)),
        );
      }
    } catch (error) {
      // If saved data is ever unreadable, start with the samples instead of crashing.
      debugPrint('Could not load saved data: $error');
      _decks
        ..clear()
        ..addAll(buildSampleDecks());
      _hasOnboarded = true;
    }
    notifyListeners();
  }

  /// Saves the choices from the welcome screen.
  Future<void> completeOnboarding({
    required String name,
    required List<Deck> decks,
  }) async {
    _userName = _cleanName(name);
    _decks
      ..clear()
      ..addAll(decks);
    _hasOnboarded = true;
    notifyListeners();

    await _saveName();
    await _prefs?.setBool(_onboardedKey, true);
    await _saveDecks();
  }

  void setUserName(String name) {
    _userName = _cleanName(name);
    notifyListeners();
    _saveName();
  }

  /// Adds any sample decks the user doesn't already have.
  /// Returns how many were added.
  int addSampleDecks() {
    final existingIds = _decks.map((deck) => deck.id).toSet();
    final missing = buildSampleDecks()
        .where((deck) => !existingIds.contains(deck.id))
        .toList();
    if (missing.isEmpty) return 0;

    _decks.addAll(missing);
    _changed();
    return missing.length;
  }

  void addDeck(Deck deck) {
    _decks.add(deck);
    _changed();
  }

  void removeDeck(Deck deck) {
    _decks.remove(deck);
    _changed();
  }

  void addCard(Deck deck, Flashcard card) {
    deck.cards.add(card);
    _changed();
  }

  void insertCard(Deck deck, int index, Flashcard card) {
    deck.cards.insert(index.clamp(0, deck.cards.length), card);
    _changed();
  }

  void removeCardAt(Deck deck, int index) {
    deck.cards.removeAt(index);
    _changed();
  }

  void recordScore(Deck deck, int percent) {
    final best = deck.bestPercent;
    if (best == null || percent > best) {
      deck.bestPercent = percent;
      _changed();
    }
  }

  // ---------------------------------------------------------------------------
  // Saving
  // ---------------------------------------------------------------------------

  /// Updates the screen and saves the decks. Every deck change goes through here.
  void _changed() {
    notifyListeners();
    _saveDecks();
  }

  Future<void> _saveDecks() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final json = jsonEncode(_decks.map((deck) => deck.toJson()).toList());
    await prefs.setString(_decksKey, json);
  }

  Future<void> _saveName() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final name = _userName;
    if (name == null) {
      await prefs.remove(_nameKey);
    } else {
      await prefs.setString(_nameKey, name);
    }
  }

  static String? _cleanName(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// One shared store for the whole app.
final deckStore = DeckStore();
