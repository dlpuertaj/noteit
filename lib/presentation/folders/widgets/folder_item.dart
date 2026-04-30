import 'package:flutter/material.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/use_cases/delete_folder.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/presentation/folders/widgets/note_item.dart';

class FolderItem extends StatelessWidget {
  const FolderItem({
    super.key,
    required this.folder,
    required this.notes,
    required this.childItems,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
    required this.onNoteSelected,
    required this.onDeleteNote,
    required this.onMoveNote,
    required this.onDeleteFolder,
    required this.onRenameFolder,
  });

  final Folder folder;
  final List<Note> notes;
  final List<Widget> childItems;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(String noteId) onNoteSelected;
  final void Function(String noteId) onDeleteNote;
  final void Function(String noteId) onMoveNote;
  final void Function(DeleteFolderAction action) onDeleteFolder;
  final void Function(String newName) onRenameFolder;

  Future<void> _showFolderContextMenu(
      BuildContext context, Offset position) async {
    if (folder.isSystem) return;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );

    if (!context.mounted) return;

    if (result == 'rename') {
      final controller = TextEditingController(text: folder.name);
      final newName = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rename folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Folder name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Rename'),
            ),
          ],
        ),
      );
      if (newName != null && newName.isNotEmpty) onRenameFolder(newName);
    }

    if (!context.mounted) return;

    if (result == 'delete') {
      final noteCount = notes.length;
      if (noteCount == 0) {
        onDeleteFolder(DeleteFolderAction.deletePermanently);
      } else {
        final action = await showDialog<DeleteFolderAction>(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
              'This folder contains $noteCount note${noteCount == 1 ? '' : 's'}. '
              'What do you want to do with them?',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(DeleteFolderAction.moveToStash),
                child: const Text('Move to Stash'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(DeleteFolderAction.deletePermanently),
                child: const Text('Delete permanently'),
              ),
            ],
          ),
        );
        if (action != null) onDeleteFolder(action);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPressStart: (details) =>
              _showFolderContextMenu(context, details.globalPosition),
          child: ListTile(
            tileColor: isSelected
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5)
                : null,
            leading: Icon(isExpanded ? Icons.folder_open : Icons.folder),
            title: Text(folder.name),
            onTap: onTap,
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                ...childItems,
                ...notes.map((note) => NoteItem(
                      note: note,
                      onTap: () => onNoteSelected(note.id),
                      onDelete: () => onDeleteNote(note.id),
                      onMove: () => onMoveNote(note.id),
                    )),
              ],
            ),
          ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: folder.depth > 1
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
              ),
              child: content,
            )
          : content,
    );
  }
}
