import 'package:flutter/material.dart';

import '../data/deck_icons.dart';
import '../models/deck.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for creating a deck. Returns the new [Deck], or null if closed.
class NewDeckSheet extends StatefulWidget {
  const NewDeckSheet({super.key});

  @override
  State<NewDeckSheet> createState() => _NewDeckSheetState();
}

class _NewDeckSheetState extends State<NewDeckSheet> {
  final _title = TextEditingController();
  String _iconName = pickableDeckIcons.first;
  Color _color = AppColors.deckPalette.first;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _create() {
    Navigator.pop(
      context,
      Deck(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        iconName: _iconName,
        color: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboard),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New deck', style: displayStyle(26)),
          const SizedBox(height: 16),

          // Live preview that updates as you type and pick.
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 84,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(deckIcons[_iconName], color: AppColors.ink, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _title,
                    builder: (context, value, _) => Text(
                      value.text.trim().isEmpty ? 'Deck name' : value.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: displayStyle(
                        21,
                        color: AppColors.ink.withValues(
                          alpha: value.text.trim().isEmpty ? 0.45 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'e.g. Operating Systems',
            ),
            onSubmitted: (_) {
              if (_title.text.trim().isNotEmpty) _create();
            },
          ),
          const SizedBox(height: 20),
          const Text('Icon', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in pickableDeckIcons)
                GestureDetector(
                  onTap: () => setState(() => _iconName = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: name == _iconName ? _color : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      deckIcons[name],
                      size: 24,
                      color: name == _iconName ? _color : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Color', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in AppColors.deckPalette)
                GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == _color
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: color == _color
                        ? const Icon(
                            Icons.check,
                            color: AppColors.ink,
                            size: 20,
                          )
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _title,
            builder: (context, value, _) => FilledButton(
              style: filledStyle(_color),
              onPressed: value.text.trim().isEmpty ? null : _create,
              child: const Text('Create deck'),
            ),
          ),
        ],
      ),
    );
  }
}
