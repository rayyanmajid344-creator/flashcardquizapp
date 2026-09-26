import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/deck_store.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';
import '../widgets/index_card.dart';
import '../widgets/session_widgets.dart';
import 'results_screen.dart';

/// Timed multiple choice. Wrong options are taken from other answers in the deck.
/// Keyboard: press 1–4 to answer.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.deck, this.cards});

  final Deck deck;
  final List<Flashcard>? cards;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

enum _OptionState { idle, correct, wrong, faded }

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  static const _questionTime = Duration(seconds: 15);
  static const _numberKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
  ];

  final _random = Random();
  late final List<Flashcard> _cards;
  late final AnimationController _timer;
  final List<Flashcard> _missed = [];
  List<String> _options = [];

  int _index = 0;
  int _correct = 0;
  int _points = 0;
  int _streak = 0;
  int _bestStreak = 0;
  String? _picked;
  bool _locked = false;
  Timer? _nextQuestion;

  @override
  void initState() {
    super.initState();
    _cards = List.of(widget.cards ?? widget.deck.cards)..shuffle(_random);
    _timer = AnimationController(vsync: this, duration: _questionTime)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _lockIn(null); // time's up
      });
    _prepareQuestion();
  }

  @override
  void dispose() {
    _nextQuestion?.cancel();
    _timer.dispose();
    super.dispose();
  }

  void _prepareQuestion() {
    final answer = _cards[_index].answer;
    final wrongAnswers =
        widget.deck.cards
            .map((c) => c.answer)
            .where((a) => a != answer)
            .toSet()
            .toList()
          ..shuffle(_random);

    _options = [answer, ...wrongAnswers.take(3)]..shuffle(_random);
    _picked = null;
    _locked = false;
    _timer.forward(from: 0);
  }

  void _lockIn(String? picked) {
    if (_locked) return;
    _timer.stop();

    final card = _cards[_index];
    final isRight = picked == card.answer;

    setState(() {
      _locked = true;
      _picked = picked;
      if (isRight) {
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        final timeBonus = ((1 - _timer.value) * 10).round();
        final streakBonus = _streak >= 3 ? 5 : 0;
        _points += 10 + timeBonus + streakBonus;
      } else {
        _streak = 0;
        _missed.add(card);
      }
    });

    _nextQuestion = Timer(const Duration(milliseconds: 1300), _goToNext);
  }

  void _goToNext() {
    if (!mounted) return;
    if (_index + 1 >= _cards.length) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _prepareQuestion();
    });
  }

  void _finish() {
    final percent = (_correct * 100 / _cards.length).round();
    final isFullDeck = widget.cards == null;
    final previousBest = widget.deck.bestPercent;
    if (isFullDeck) deckStore.recordScore(widget.deck, percent);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          deck: widget.deck,
          mode: SessionMode.quiz,
          correct: _correct,
          total: _cards.length,
          bestStreak: _bestStreak,
          points: _points,
          missed: List.of(_missed),
          isNewBest:
              isFullDeck && (previousBest == null || percent > previousBest),
        ),
      ),
    );
  }

  _OptionState _stateFor(String option, String answer) {
    if (!_locked) return _OptionState.idle;
    if (option == answer) return _OptionState.correct;
    if (option == _picked) return _OptionState.wrong;
    return _OptionState.faded;
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    final card = _cards[_index];

    return CallbackShortcuts(
      bindings: {
        for (var i = 0; i < _options.length; i++)
          SingleActivator(_numberKeys[i]): () => _lockIn(_options[i]),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(deck.title),
            actions: [
              StreakBadge(streak: _streak),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProgressHeader(
                        index: _index,
                        total: _cards.length,
                        color: deck.color,
                        trailing: TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: _points),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, _) => Text(
                            '$value pts',
                            style: TextStyle(
                              color: deck.color,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _TimerBar(
                        timer: _timer,
                        totalSeconds: _questionTime.inSeconds,
                        color: deck.color,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: IndexCard(
                          label: 'Question',
                          text: card.question,
                          accent: deck.color,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < _options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _OptionTile(
                            number: i + 1,
                            text: _options[i],
                            state: _stateFor(_options[i], card.answer),
                            accent: deck.color,
                            onTap: _locked ? null : () => _lockIn(_options[i]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Countdown bar that turns red as time runs out.
class _TimerBar extends StatelessWidget {
  const _TimerBar({
    required this.timer,
    required this.totalSeconds,
    required this.color,
  });

  final AnimationController timer;
  final int totalSeconds;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timer,
      builder: (context, _) {
        final remaining = 1 - timer.value;
        final barColor = Color.lerp(
          AppColors.wrong,
          color,
          (remaining * 2).clamp(0.0, 1.0).toDouble(),
        )!;
        final secondsLeft = (totalSeconds * remaining).ceil();

        return Row(
          children: [
            Icon(Icons.timer_outlined, color: barColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: remaining,
                  minHeight: 8,
                  color: barColor,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 28,
              child: Text(
                '$secondsLeft',
                textAlign: TextAlign.right,
                style: TextStyle(color: barColor, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.number,
    required this.text,
    required this.state,
    required this.accent,
    required this.onTap,
  });

  final int number;
  final String text;
  final _OptionState state;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    var background = AppColors.surface;
    var border = Colors.white12;
    var badge = AppColors.surfaceHigh;
    var badgeText = AppColors.textPrimary;
    IconData? icon;

    switch (state) {
      case _OptionState.correct:
        background = AppColors.correct.withValues(alpha: 0.16);
        border = AppColors.correct;
        badge = AppColors.correct;
        badgeText = AppColors.ink;
        icon = Icons.check_circle;
      case _OptionState.wrong:
        background = AppColors.wrong.withValues(alpha: 0.16);
        border = AppColors.wrong;
        badge = AppColors.wrong;
        badgeText = AppColors.ink;
        icon = Icons.cancel;
      case _OptionState.idle:
      case _OptionState.faded:
        break;
    }

    // Wrong answers give a little shake.
    return TweenAnimationBuilder<double>(
      key: ValueKey(state),
      tween: Tween(begin: 0, end: state == _OptionState.wrong ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      builder: (context, t, child) => Transform.translate(
        offset: Offset(sin(t * pi * 6) * 8 * (1 - t), 0),
        child: child,
      ),
      child: AnimatedOpacity(
        opacity: state == _OptionState.faded ? 0.4 : 1,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 2),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              hoverColor: accent.withValues(alpha: 0.1),
              splashColor: accent.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badge,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$number',
                        style: TextStyle(
                          color: badgeText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (icon != null) Icon(icon, color: border),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
