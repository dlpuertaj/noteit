import 'package:flutter/material.dart';

class NoteThreeDotMenu extends StatelessWidget {
  const NoteThreeDotMenu({super.key, required this.onDeleteNote});

  final VoidCallback onDeleteNote;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More options',
      onSelected: (value) {
        if (value == 'delete') onDeleteNote();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'delete', child: Text('Delete note')),
      ],
    );
  }
}
