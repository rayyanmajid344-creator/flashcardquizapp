import 'package:flutter/material.dart';

import '../data/deck_store.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';
import '../widgets/add_card_dialog.dart';
import '../widgets/stripe_band.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key, required this.deck});

  final Deck deck;

  Future<void> _addCard(BuildContext context) async {
    final card = await showDialog<Flashcard>(
      context: context,
      builder: (_) => AddCardDialog(accent: deck.color),
    );
    if (card != null) deckStore.addCard(deck, card);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete "${deck.title}"?', style: displayStyle(22)),
        content: const Text(
          'This removes the deck and all of its cards.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.wrong,
              foregroundColor: AppColors.ink,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete deck'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.pop(context);
    deckStore.removeDeck(deck);
  }

  void _deleteCard(BuildContext context, int index) {
    final removed = deck.cards[index];
    deckStore.removeCardAt(deck, index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Card deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => deckStore.insertCard(deck, index, removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: deckStore,
      builder: (context, _) {
        final cards = deck.cards;

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: 'Delete deck',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addCard(context),
            backgroundColor: deck.color,
            foregroundColor: AppColors.ink,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add card',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                children: [
                  _DeckHeader(deck: deck),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeButton(
                          icon: Icons.swipe_outlined,
                          title: 'Study',
                          subtitle: 'Flip and swipe',
                          color: deck.color,
                          enabled: cards.isNotEmpty,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudyScreen(deck: deck),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeButton(
                          icon: Icons.timer_outlined,
                          title: 'Quiz',
                          subtitle: 'Timed multiple choice',
                          color: deck.color,
                          enabled: cards.length >= 2,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(deck: deck),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('Cards (${cards.length})', style: displayStyle(22)),
                  const SizedBox(height: 4),
                  if (cards.isNotEmpty)
                    const Text(
                      'Swipe a card sideways to delete it.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (cards.isEmpty)
                    _EmptyState(
                      color: deck.color,
                      onAdd: () => _addCard(context),
                    ),
                  for (var i = 0; i < cards.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ObjectKey(cards[i]),
                        background: const _DeleteBackground(
                          alignment: Alignment.centerLeft,
                        ),
                        secondaryBackground: const _DeleteBackground(
                          alignment: Alignment.centerRight,
                        ),
                        onDismissed: (_) => _deleteCard(context, i),
                        child: _CardRow(card: cards[i], color: deck.color),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final best = deck.bestPercent;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: deck.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StripeBand(color: AppColors.ink, height: 20, stripes: 11),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Hero(
                  tag: 'deck-icon-${deck.id}',
                  child: Icon(deck.icon, color: AppColors.ink, size: 48),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.title,
                        style: displayStyle(28, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        best == null
                            ? plural(deck.cards.length, 'card')
                            : '${plural(deck.cards.length, 'card')}   Best score $best%',
                        style: TextStyle(
                          color: AppColors.ink.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          hoverColor: color.withValues(alpha: 0.08),
          splashColor: color.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.ink),
                ),
                const SizedBox(height: 14),
                Text(title, style: displayStyle(21)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.color});

  final Flashcard card;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.answer,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.wrong,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.delete_outline, color: AppColors.ink),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color, required this.onAdd});

  final Color color;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.style_rounded, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 10),
          const Text(
            'No cards yet. Add your first one to start studying.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.ink,
            ),
            onPressed: onAdd,
            child: const Text('Add card'),
          ),
        ],
      ),
    );
  }
}
