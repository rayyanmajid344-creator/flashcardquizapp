import 'package:flutter/material.dart';

import '../data/deck_store.dart';
import '../data/sample_decks.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// First-launch welcome: asks for a name and which sample decks to start with.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  final _sampleDecks = buildSampleDecks();
  final Set<String> _selectedIds = {};
  bool _saving = false;

  bool get _hasName => _name.text.trim().isNotEmpty;
  bool get _allSelected => _selectedIds.length == _sampleDecks.length;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toggle(Deck deck) {
    setState(() {
      if (!_selectedIds.remove(deck.id)) _selectedIds.add(deck.id);
    });
  }

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_sampleDecks.map((deck) => deck.id));
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final chosen = _sampleDecks
        .where((deck) => _selectedIds.contains(deck.id))
        .toList();
    await deckStore.completeOnboarding(name: _name.text, decks: chosen);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fadeRoute(const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              children: [
                Text('Welcome!', style: displayStyle(42)),
                const SizedBox(height: 8),
                const Text(
                  "Let's set things up. It only takes a moment.",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
                const SizedBox(height: 36),
                Text('What should we call you?', style: displayStyle(21)),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Your first name',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pick decks to start with',
                        style: displayStyle(21),
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleAll,
                      child: Text(_allSelected ? 'Clear' : 'Select all'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Or skip them and make your own. You can add these later from the menu.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
                for (final deck in _sampleDecks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DeckChoice(
                      deck: deck,
                      selected: _selectedIds.contains(deck.id),
                      onTap: () => _toggle(deck),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  style: filledStyle(AppColors.cerulean),
                  onPressed: _hasName && !_saving ? _finish : null,
                  child: Text(
                    _selectedIds.isEmpty ? 'Start with no decks' : "Let's go",
                  ),
                ),
                if (!_hasName) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your name to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckChoice extends StatelessWidget {
  const _DeckChoice({
    required this.deck,
    required this.selected,
    required this.onTap,
  });

  final Deck deck;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 200);
    final textColor = selected ? AppColors.ink : AppColors.textPrimary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? deck.color : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? deck.color : Colors.white12,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: duration,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.ink.withValues(alpha: 0.12)
                      : deck.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(deck.icon, color: AppColors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      plural(deck.cards.length, 'card'),
                      style: TextStyle(
                        color: selected
                            ? AppColors.ink.withValues(alpha: 0.7)
                            : AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: duration,
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  key: ValueKey(selected),
                  color: selected ? AppColors.ink : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
