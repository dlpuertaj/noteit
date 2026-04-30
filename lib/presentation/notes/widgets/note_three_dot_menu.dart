import 'package:flutter/material.dart';

class NoteThreeDotMenu extends StatelessWidget {
  const NoteThreeDotMenu({
    super.key,
    required this.onDeleteNote,
    required this.onMoveNote,
  });

  final VoidCallback onDeleteNote;
  final VoidCallback onMoveNote;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More options',
      onSelected: (value) {
        if (value == 'delete') onDeleteNote();
        if (value == 'move') onMoveNote();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'delete', child: Text('Delete note')),
        PopupMenuItem(value: 'move', child: Text('Move to...')),
      ],
    );
  }
}
