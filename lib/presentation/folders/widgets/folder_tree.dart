import 'package:flutter/material.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/use_cases/delete_folder.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/presentation/folders/widgets/folder_item.dart';

class FolderTree extends StatelessWidget {
  const FolderTree({
    super.key,
    required this.folders,
    required this.allNotes,
    required this.expandedFolderIds,
    required this.onFolderTap,
    required this.onNoteSelected,
    required this.onDeleteNote,
    required this.onMoveNote,
    required this.onDeleteFolder,
  });

  final List<Folder> folders;
  final List<Note> allNotes;
  final Set<String> expandedFolderIds;
  final void Function(String folderId) onFolderTap;
  final void Function(String noteId) onNoteSelected;
  final void Function(String noteId) onDeleteNote;
  final void Function(String noteId) onMoveNote;
  final void Function(String folderId, DeleteFolderAction action)
      onDeleteFolder;

  @override
  Widget build(BuildContext context) {
    final systemFolders = folders.where((f) => f.isSystem).toList();
    final userFolders = folders.where((f) => !f.isSystem).toList();
    final ordered = [...systemFolders, ...userFolders];

    return ListView(
      children: ordered.map((folder) {
        final notes =
            allNotes.where((n) => n.folderId == folder.id).toList();
        return FolderItem(
          folder: folder,
          notes: notes,
          isExpanded: expandedFolderIds.contains(folder.id),
          onTap: () => onFolderTap(folder.id),
          onNoteSelected: onNoteSelected,
          onDeleteNote: onDeleteNote,
          onMoveNote: onMoveNote,
          onDeleteFolder: (action) => onDeleteFolder(folder.id, action),
        );
      }).toList(),
    );
  }
}
