import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti.dart';
import '../widgets/score_ring.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

enum SessionMode { study, quiz }

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.deck,
    required this.mode,
    required this.correct,
    required this.total,
    required this.bestStreak,
    required this.missed,
    required this.isNewBest,
    this.points,
  });

  final Deck deck;
  final SessionMode mode;
  final int correct;
  final int total;
  final int bestStreak;
  final List<Flashcard> missed;
  final bool isNewBest;
  final int? points; // quiz only

  String _headline(double percent) {
    if (percent == 1) return 'Perfect run!';
    if (percent >= 0.8) return 'Great work!';
    if (percent >= 0.5) return 'Nice progress.';
    return 'Keep practicing, you\'ll get there.';
  }

  void _restart(BuildContext context, {List<Flashcard>? onlyThese}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => mode == SessionMode.quiz && onlyThese == null
            ? QuizScreen(deck: deck)
            : StudyScreen(deck: deck, cards: onlyThese),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : correct / total;
    final celebrate =
        percent >= 0.8 && !MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(deck.icon, color: AppColors.textMuted, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              deck.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ScoreRing(percent: percent, color: deck.color),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _headline(percent),
                        textAlign: TextAlign.center,
                        style: displayStyle(32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You got $correct of $total right.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      if (isNewBest) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: deck.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.ink,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'New personal best',
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(label: 'Correct', value: '$correct'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Stat(
                              label: 'Best streak',
                              value: '$bestStreak',
                            ),
                          ),
                          if (points != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Stat(label: 'Points', value: '$points'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (missed.isNotEmpty) ...[
                        FilledButton(
                          style: filledStyle(deck.color),
                          onPressed: () => _restart(context, onlyThese: missed),
                          child: Text(
                            'Review ${plural(missed.length, 'missed card')}',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: outlinedStyle(),
                          onPressed: () => _restart(context),
                          child: const Text('Try again'),
                        ),
                      ] else
                        FilledButton(
                          style: filledStyle(deck.color),
                          onPressed: () => _restart(context),
                          child: const Text('Try again'),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to deck',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (celebrate) const Positioned.fill(child: ConfettiBurst()),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
