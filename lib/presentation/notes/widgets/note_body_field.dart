import 'package:flutter/material.dart';

class NoteBodyField extends StatelessWidget {
  const NoteBodyField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('note_body_field'),
      controller: controller,
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
