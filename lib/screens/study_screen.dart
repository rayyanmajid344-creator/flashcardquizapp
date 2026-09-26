import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/deck_store.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';
import '../widgets/flip_card.dart';
import '../widgets/index_card.dart';
import '../widgets/session_widgets.dart';
import 'results_screen.dart';

/// Flip a card, then swipe right if you knew it or left if you didn't.
/// Keyboard: Space flips, → = got it, ← = missed it.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deck, this.cards});

  final Deck deck;

  /// Optional subset to study (e.g. only the cards you missed).
  final List<Flashcard>? cards;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late final List<Flashcard> _cards;
  final List<Flashcard> _missed = [];
  int _index = 0;
  int _correct = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _showAnswer = false;

  // Swipe state.
  Offset _drag = Offset.zero;
  double _cardWidth = 400;
  late final AnimationController _controller;
  Animation<Offset>? _dragAnimation;

  bool get _isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _cards = List.of(widget.cards ?? widget.deck.cards)..shuffle();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addListener(() {
          final animation = _dragAnimation;
          if (animation != null) setState(() => _drag = animation.value);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isAnimating) return;
    setState(() => _showAnswer = !_showAnswer);
  }

  void _animateDragTo(Offset target, {VoidCallback? then}) {
    _dragAnimation = Tween<Offset>(
      begin: _drag,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) then?.call();
    });
  }

  /// Throws the card off screen, then records the answer.
  void _swipe(bool knewIt) {
    if (_isAnimating) return;
    final direction = knewIt ? 1.0 : -1.0;
    _animateDragTo(
      Offset(direction * _cardWidth * 1.6, _drag.dy + 40),
      then: () => _record(knewIt),
    );
  }

  void _record(bool knewIt) {
    if (knewIt) {
      _correct++;
      _streak++;
      _bestStreak = max(_bestStreak, _streak);
    } else {
      _streak = 0;
      _missed.add(_cards[_index]);
    }

    if (_index + 1 >= _cards.length) {
      _finish();
      return;
    }

    setState(() {
      _index++;
      _showAnswer = false;
      _drag = Offset.zero;
      _dragAnimation = null;
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
          mode: SessionMode.study,
          correct: _correct,
          total: _cards.length,
          bestStreak: _bestStreak,
          missed: List.of(_missed),
          isNewBest:
              isFullDeck && (previousBest == null || percent > previousBest),
        ),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() => _drag += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    final threshold = _cardWidth * 0.28;
    final flick = details.velocity.pixelsPerSecond.dx;

    if (_drag.dx > threshold || flick > 900) {
      _swipe(true);
    } else if (_drag.dx < -threshold || flick < -900) {
      _swipe(false);
    } else {
      _animateDragTo(Offset.zero); // snap back
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    final card = _cards[_index];
    final swipeProgress = (_drag.dx / (_cardWidth * 0.28))
        .clamp(-1.0, 1.0)
        .toDouble();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): _flip,
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _swipe(true),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _swipe(false),
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
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      ProgressHeader(
                        index: _index,
                        total: _cards.length,
                        color: deck.color,
                        trailing: Text(
                          '$_correct correct',
                          style: TextStyle(
                            color: deck.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            _cardWidth = constraints.maxWidth;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // The next card peeking out from underneath.
                                if (_index + 1 < _cards.length)
                                  Positioned.fill(
                                    child: Transform.translate(
                                      offset: const Offset(0, 16),
                                      child: Transform.scale(
                                        scale: 0.93,
                                        child: IndexCard(
                                          label: '',
                                          text: '',
                                          accent: deck.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: _flip,
                                    onPanUpdate: _onPanUpdate,
                                    onPanEnd: _onPanEnd,
                                    child: Transform.translate(
                                      offset: _drag,
                                      child: Transform.rotate(
                                        angle: _drag.dx / _cardWidth * 0.35,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: FlipCard(
                                                key: ValueKey(_index),
                                                showBack: _showAnswer,
                                                front: IndexCard(
                                                  label: 'Question',
                                                  text: card.question,
                                                  accent: deck.color,
                                                ),
                                                back: IndexCard(
                                                  label: 'Answer',
                                                  text: card.answer,
                                                  accent: deck.color,
                                                ),
                                              ),
                                            ),
                                            if (swipeProgress > 0)
                                              Positioned(
                                                top: 24,
                                                left: 20,
                                                child: _Stamp(
                                                  text: 'Got it',
                                                  color: AppColors.correct,
                                                  opacity: swipeProgress,
                                                  angle: -0.2,
                                                ),
                                              ),
                                            if (swipeProgress < 0)
                                              Positioned(
                                                top: 24,
                                                right: 20,
                                                child: _Stamp(
                                                  text: 'Missed',
                                                  color: AppColors.wrong,
                                                  opacity: -swipeProgress,
                                                  angle: 0.2,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _showAnswer
                            ? 'Swipe right if you knew it, left if you didn\'t.'
                            : 'Tap the card to flip it.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      if (_showAnswer)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _swipe(false),
                                style: outlinedStyle(),
                                icon: const Icon(Icons.close),
                                label: const Text('Missed it'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _swipe(true),
                                style: filledStyle(deck.color),
                                icon: const Icon(Icons.check),
                                label: const Text('Got it'),
                              ),
                            ),
                          ],
                        )
                      else
                        FilledButton(
                          onPressed: _flip,
                          style: filledStyle(deck.color),
                          child: const Text('Show answer'),
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

/// The rubber-stamp label that fades in while you drag a card.
class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.text,
    required this.color,
    required this.opacity,
    required this.angle,
  });

  final String text;
  final Color color;
  final double opacity;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text, style: displayStyle(22, color: color, height: 1.2)),
        ),
      ),
    );
  }
}
