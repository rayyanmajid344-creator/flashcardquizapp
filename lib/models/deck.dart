import 'package:flutter/material.dart';

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

class Deck {
  Deck({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    List<Flashcard>? cards,
  }) : cards = cards ?? <Flashcard>[];

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<Flashcard> cards;

  /// Best score (0–100) from a full run through this deck.
  int? bestPercent;
}

/// "1 card", "5 cards"
String plural(int count, String word) => '$count $word${count == 1 ? '' : 's'}';
