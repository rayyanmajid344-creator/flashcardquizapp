import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../theme/app_theme.dart';

/// Dialog for writing a new card. Returns the [Flashcard], or null if cancelled.
class AddCardDialog extends StatefulWidget {
  const AddCardDialog({super.key, required this.accent});

  final Color accent;

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _question = TextEditingController();
  final _answer = TextEditingController();

  bool get _isValid =>
      _question.text.trim().isNotEmpty && _answer.text.trim().isNotEmpty;

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('New card', style: displayStyle(24)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _question,
              autofocus: true,
              minLines: 1,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Question'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answer,
              minLines: 1,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Answer'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: widget.accent,
            foregroundColor: AppColors.ink,
          ),
          onPressed: _isValid
              ? () => Navigator.pop(
                  context,
                  Flashcard(
                    question: _question.text.trim(),
                    answer: _answer.text.trim(),
                  ),
                )
              : null,
          child: const Text('Add card'),
        ),
      ],
    );
  }
}
