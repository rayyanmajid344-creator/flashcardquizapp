import 'package:flutter/material.dart';

/// Every icon a deck can use, saved by name.
///
/// We save the name (e.g. 'book') instead of the icon itself, because
/// Flutter's release builds only include icons written directly in the code.
const Map<String, IconData> deckIcons = {
  'tree': Icons.account_tree_rounded,
  'puzzle': Icons.extension_rounded,
  'network': Icons.lan_rounded,
  'storage': Icons.storage_rounded,
  'globe': Icons.public_rounded,
  'book': Icons.menu_book_rounded,
  'brain': Icons.psychology_rounded,
  'code': Icons.code_rounded,
  'science': Icons.science_rounded,
  'calculator': Icons.calculate_rounded,
  'palette': Icons.palette_rounded,
  'language': Icons.translate_rounded,
  'rocket': Icons.rocket_launch_rounded,
};

/// The icons offered when creating a new deck.
const List<String> pickableDeckIcons = [
  'book',
  'brain',
  'code',
  'science',
  'calculator',
  'palette',
  'language',
  'rocket',
];
