import 'dart:math';

import 'package:flutter/material.dart';

import '../data/deck_store.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';
import '../widgets/new_deck_sheet.dart';
import '../widgets/stripe_band.dart';
import 'deck_screen.dart';

enum _MenuAction { changeName, addSamples }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _createDeck(BuildContext context) async {
    final deck = await showModalBottomSheet<Deck>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NewDeckSheet(),
    );
    if (deck == null) return;

    deckStore.addDeck(deck);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeckScreen(deck: deck)),
    );
  }

  Future<void> _changeName(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initialName: deckStore.userName ?? ''),
    );
    if (name != null) deckStore.setUserName(name);
  }

  void _addSampleDecks(BuildContext context) {
    final added = deckStore.addSampleDecks();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added == 0
                ? 'You already have all the sample decks.'
                : 'Added ${plural(added, 'sample deck')}.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDeck(context),
        backgroundColor: AppColors.deckPalette[0],
        foregroundColor: AppColors.ink,
        icon: const Icon(Icons.add),
        label: const Text(
          'New deck',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: deckStore,
          builder: (context, _) {
            final decks = deckStore.decks;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 12, 8),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      userName: deckStore.userName,
                      deckCount: decks.length,
                      cardCount: deckStore.totalCards,
                      onMenuSelected: (action) {
                        switch (action) {
                          case _MenuAction.changeName:
                            _changeName(context);
                          case _MenuAction.addSamples:
                            _addSampleDecks(context);
                        }
                      },
                    ),
                  ),
                ),
                if (decks.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                    sliver: SliverToBoxAdapter(
                      child: _EmptyHome(onCreate: () => _createDeck(context)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 22,
                            childAspectRatio: 0.95,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => DeckTile(
                          deck: decks[i],
                          // Alternate tilts so the tiles look casually placed.
                          tilt: i.isEven ? -0.03 : 0.025,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeckScreen(deck: decks[i]),
                            ),
                          ),
                        ),
                        childCount: decks.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.userName,
    required this.deckCount,
    required this.cardCount,
    required this.onMenuSelected,
  });

  final String? userName;
  final int deckCount;
  final int cardCount;
  final ValueChanged<_MenuAction> onMenuSelected;

  /// Changes with the time of day, and includes the name if we have one.
  String get _greeting {
    final hour = DateTime.now().hour;
    final timeOfDay = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return userName == null ? timeOfDay : '$timeOfDay, $userName';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _greeting,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PopupMenuButton<_MenuAction>(
              tooltip: 'Menu',
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textPrimary,
              ),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: onMenuSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MenuAction.changeName,
                  child: _MenuRow(
                    icon: Icons.badge_outlined,
                    label: 'Change name',
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.addSamples,
                  child: _MenuRow(
                    icon: Icons.library_add_outlined,
                    label: 'Add sample decks',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            'What are we studying today?',
            style: displayStyle(36, height: 1.1),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(plural(deckCount, 'deck')),
            _Pill(plural(cardCount, 'card')),
          ],
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.style_rounded, color: AppColors.textMuted, size: 44),
          const SizedBox(height: 12),
          Text('No decks yet', style: displayStyle(24)),
          const SizedBox(height: 6),
          const Text(
            'Create your first deck, or add the sample decks from the menu at the top.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cerulean,
              foregroundColor: AppColors.ink,
            ),
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('New deck'),
          ),
        ],
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initialName});

  final String initialName;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Your name', style: displayStyle(24)),
      content: SizedBox(
        width: 380,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Your first name'),
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cerulean,
            foregroundColor: AppColors.ink,
          ),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// A colorful deck tile that straightens up and lifts when you hover over it.
class DeckTile extends StatefulWidget {
  const DeckTile({
    super.key,
    required this.deck,
    required this.tilt,
    required this.onTap,
  });

  final Deck deck;
  final double tilt; // radians
  final VoidCallback onTap;

  @override
  State<DeckTile> createState() => _DeckTileState();
}

class _DeckTileState extends State<DeckTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    const duration = Duration(milliseconds: 180);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.05 : 1,
          duration: duration,
          child: AnimatedRotation(
            turns: _hovered ? 0 : widget.tilt / (2 * pi),
            duration: duration,
            child: AnimatedContainer(
              duration: duration,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: deck.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: deck.color.withValues(alpha: _hovered ? 0.45 : 0.18),
                    blurRadius: _hovered ? 30 : 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StripeBand(
                    color: AppColors.ink,
                    height: 16,
                    stripes: 7,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'deck-icon-${deck.id}',
                            child: Icon(
                              deck.icon,
                              color: AppColors.ink,
                              size: 32,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            deck.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: displayStyle(
                              19,
                              color: AppColors.ink,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                plural(deck.cards.length, 'card'),
                                style: TextStyle(
                                  color: AppColors.ink.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (deck.bestPercent != null) ...[
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.ink,
                                  size: 16,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${deck.bestPercent}%',
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
