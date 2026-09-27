import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';
import 'sample_decks.dart';

/// Holds all decks, tells the UI when something changes,
/// and saves everything to the device so it survives restarts.
///
/// Screens rebuild by wrapping themselves in a ListenableBuilder(listenable: deckStore).
class DeckStore extends ChangeNotifier {
  static const _storageKey = 'decks_v1';

  final List<Deck> _decks = [];
  SharedPreferences? _prefs;

  List<Deck> get decks => List.unmodifiable(_decks);

  int get totalCards =>
      _decks.fold<int>(0, (sum, deck) => sum + deck.cards.length);

  /// Called once when the app starts (see main.dart).
  /// Loads saved decks, or the sample decks on the very first launch.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final saved = _prefs!.getString(_storageKey);

      _decks.clear();
      if (saved == null) {
        _decks.addAll(buildSampleDecks());
      } else {
        final list = jsonDecode(saved) as List<dynamic>;
        _decks.addAll(
          list.map((json) => Deck.fromJson(json as Map<String, dynamic>)),
        );
      }
    } catch (error) {
      // If saved data is ever unreadable, start fresh instead of crashing.
      debugPrint('Could not load saved decks: $error');
      _decks
        ..clear()
        ..addAll(buildSampleDecks());
    }
    notifyListeners();
  }

  /// Updates the screen and saves. Every change goes through here.
  void _changed() {
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final json = jsonEncode(_decks.map((deck) => deck.toJson()).toList());
    await prefs.setString(_storageKey, json);
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
}

/// One shared store for the whole app.
final deckStore = DeckStore();
