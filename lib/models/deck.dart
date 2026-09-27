import 'package:flutter/material.dart';

import '../data/deck_icons.dart';

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});

  /// Turns the card into a map so it can be saved as JSON text.
  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};

  /// Rebuilds a card from saved JSON.
  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    question: json['question'] as String,
    answer: json['answer'] as String,
  );
}

class Deck {
  Deck({
    required this.id,
    required this.title,
    required this.iconName,
    required this.color,
    List<Flashcard>? cards,
    this.bestPercent,
  }) : cards = cards ?? <Flashcard>[];

  final String id;
  final String title;
  final String iconName;
  final Color color;
  final List<Flashcard> cards;

  /// Best score (0–100) from a full run through this deck.
  int? bestPercent;

  IconData get icon => deckIcons[iconName] ?? deckIcons['book']!;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': iconName,
    'color': color.toARGB32(),
    'bestPercent': bestPercent,
    'cards': cards.map((card) => card.toJson()).toList(),
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'] as String,
    title: json['title'] as String,
    iconName: json['icon'] as String? ?? 'book',
    color: Color(json['color'] as int),
    bestPercent: json['bestPercent'] as int?,
    cards: [
      for (final card in (json['cards'] as List<dynamic>? ?? const []))
        Flashcard.fromJson(card as Map<String, dynamic>),
    ],
  );
}

/// "1 card", "5 cards"
String plural(int count, String word) => '$count $word${count == 1 ? '' : 's'}';
