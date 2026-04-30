import 'package:flutter/material.dart';

class NoteBodyField extends StatelessWidget {
  const NoteBodyField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.undoController,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final FocusNode? focusNode;
  final UndoHistoryController? undoController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('note_body_field'),
      controller: controller,
      focusNode: focusNode,
      undoController: undoController,
      onChanged: (_) => onChanged(),
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: const InputDecoration(
        hintText: 'Start writing...',
        border: InputBorder.none,
      ),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}
