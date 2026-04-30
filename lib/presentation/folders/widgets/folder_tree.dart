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
    required this.selectedFolderId,
    required this.onFolderTap,
    required this.onNoteSelected,
    required this.onDeleteNote,
    required this.onMoveNote,
    required this.onDeleteFolder,
    required this.onRenameFolder,
  });

  final List<Folder> folders;
  final List<Note> allNotes;
  final Set<String> expandedFolderIds;
  final String? selectedFolderId;
  final void Function(String folderId) onFolderTap;
  final void Function(String noteId) onNoteSelected;
  final void Function(String noteId) onDeleteNote;
  final void Function(String noteId) onMoveNote;
  final void Function(String folderId, DeleteFolderAction action) onDeleteFolder;
  final void Function(String folderId, String newName) onRenameFolder;

  Widget _buildFolderItem(Folder folder) {
    final notes = allNotes.where((n) => n.folderId == folder.id).toList();
    final children = folders.where((f) => f.parentId == folder.id).toList();
    final childItems = children.map(_buildFolderItem).toList();

    return FolderItem(
      key: ValueKey(folder.id),
      folder: folder,
      notes: notes,
      childItems: childItems,
      isExpanded: expandedFolderIds.contains(folder.id),
      isSelected: folder.id == selectedFolderId,
      onTap: () => onFolderTap(folder.id),
      onNoteSelected: onNoteSelected,
      onDeleteNote: onDeleteNote,
      onMoveNote: onMoveNote,
      onDeleteFolder: (action) => onDeleteFolder(folder.id, action),
      onRenameFolder: (newName) => onRenameFolder(folder.id, newName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rootFolders = folders.where((f) => f.parentId == null).toList();
    final systemFolders = rootFolders.where((f) => f.isSystem).toList();
    final userFolders = rootFolders.where((f) => !f.isSystem).toList();
    final ordered = [...systemFolders, ...userFolders];

    return ListView(
      children: ordered.map(_buildFolderItem).toList(),
    );
  }
}
