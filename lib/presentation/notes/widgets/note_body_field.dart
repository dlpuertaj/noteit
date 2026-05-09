import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';

class NoteBodyField extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(settingsProvider).bodyFontSize;

    return TextField(
      key: const Key('note_body_field'),
      controller: controller,
      focusNode: focusNode,
      undoController: undoController,
      onChanged: (_) => onChanged(),
      style: TextStyle(fontSize: fontSize.toDouble()),
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
