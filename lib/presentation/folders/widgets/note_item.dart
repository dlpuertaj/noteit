import 'package:flutter/material.dart';
import 'package:notes/models/note/note.dart';

class NoteItem extends StatelessWidget {
  const NoteItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  Future<void> _showNoteContextMenu(
      BuildContext context, Offset position) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(value: 'delete', child: Text('Delete')),
        PopupMenuItem(value: 'move', child: Text('Move to...')),
      ],
    );

    if (result == 'delete') onDelete();
    if (result == 'move') onMove();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onLongPressStart: (details) =>
            _showNoteContextMenu(context, details.globalPosition),
        child: ListTile(
          leading: const Icon(Icons.note),
          title: Text(note.title.isEmpty ? 'Untitled' : note.title),
          onTap: onTap,
        ),
      ),
    );
  }
}
