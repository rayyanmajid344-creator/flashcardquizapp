import 'package:flutter/foundation.dart';

import '../models/deck.dart';
import 'sample_decks.dart';

/// Holds all decks and tells the UI when something changes.
/// Screens rebuild by wrapping themselves in a ListenableBuilder(listenable: deckStore).
class DeckStore extends ChangeNotifier {
  final List<Deck> _decks = buildSampleDecks();

  List<Deck> get decks => List.unmodifiable(_decks);

  int get totalCards =>
      _decks.fold<int>(0, (sum, deck) => sum + deck.cards.length);

  void addDeck(Deck deck) {
    _decks.add(deck);
    notifyListeners();
  }

  void removeDeck(Deck deck) {
    _decks.remove(deck);
    notifyListeners();
  }

  void addCard(Deck deck, Flashcard card) {
    deck.cards.add(card);
    notifyListeners();
  }

  void insertCard(Deck deck, int index, Flashcard card) {
    deck.cards.insert(index.clamp(0, deck.cards.length), card);
    notifyListeners();
  }

  void removeCardAt(Deck deck, int index) {
    deck.cards.removeAt(index);
    notifyListeners();
  }

  void recordScore(Deck deck, int percent) {
    final best = deck.bestPercent;
    if (best == null || percent > best) {
      deck.bestPercent = percent;
      notifyListeners();
    }
  }
}

/// One shared store for the whole app.
final deckStore = DeckStore();
