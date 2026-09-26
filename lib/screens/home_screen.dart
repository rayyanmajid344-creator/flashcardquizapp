import 'dart:math';

import 'package:flutter/material.dart';

import '../data/deck_store.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';
import '../widgets/new_deck_sheet.dart';
import '../widgets/stripe_band.dart';
import 'deck_screen.dart';

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
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      deckCount: decks.length,
                      cardCount: deckStore.totalCards,
                    ),
                  ),
                ),
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
                        // Alternate tilts so the tiles look like sticky notes on a desk.
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
  const _Header({required this.deckCount, required this.cardCount});

  final int deckCount;
  final int cardCount;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'What are we studying today?',
          style: displayStyle(36, height: 1.1),
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
