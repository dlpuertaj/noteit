import 'package:flutter/material.dart';

class NoteTitleField extends StatelessWidget {
  const NoteTitleField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('note_title_field'),
      controller: controller,
      onChanged: (_) => onChanged(),
      style: Theme.of(context).textTheme.headlineSmall,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
      ),
      maxLines: 1,
      textInputAction: TextInputAction.next,
    );
  }
}
