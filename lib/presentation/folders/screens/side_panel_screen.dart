import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/presentation/folders/providers/folder_provider.dart';
import 'package:notes/presentation/folders/widgets/folder_picker.dart';
import 'package:notes/presentation/folders/widgets/folder_tree.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';

class SidePanelScreen extends ConsumerWidget {
  const SidePanelScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  Future<void> _showNewFolderDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final folderState = ref.read(folderProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true || controller.text.trim().isEmpty) return;

    String? parentId;
    if (folderState.selectedFolderId != null) {
      final selected = folderState.folders
          .where((f) => f.id == folderState.selectedFolderId)
          .firstOrNull;
      if (selected != null &&
          !selected.isSystem &&
          selected.depth < folderState.maxFolderDepth) {
        parentId = selected.id;
      }
    }

    await ref
        .read(folderProvider.notifier)
        .createFolder(controller.text.trim(), parentId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderState = ref.watch(folderProvider);
    final allNotes = ref.watch(noteProvider).allNotes;

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FolderTree(
                folders: folderState.folders,
                allNotes: allNotes,
                expandedFolderIds: folderState.expandedFolderIds,
                selectedFolderId: folderState.selectedFolderId,
                onFolderTap: (id) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  ref.read(folderProvider.notifier).selectFolder(id);
                },
                onNoteSelected: (noteId) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await ref.read(noteProvider.notifier).loadNote(noteId);
                  onClose();
                },
                onDeleteNote: (noteId) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: const Text(
                        'Delete this note? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(noteProvider.notifier)
                        .deleteNoteById(noteId);
                  }
                },
                onMoveNote: (noteId) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FolderPicker(noteId: noteId),
                    ),
                  );
                },
                onDeleteFolder: (folderId, action) async {
                  await ref
                      .read(folderProvider.notifier)
                      .deleteFolder(folderId, action);
                  await ref.read(noteProvider.notifier).refreshNotes();
                },
                onRenameFolder: (folderId, newName) => ref
                    .read(folderProvider.notifier)
                    .renameFolder(folderId, newName),
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      await ref
                          .read(noteProvider.notifier)
                          .createNote(folderId: folderState.selectedFolderId);
                      onClose();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Note'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showNewFolderDialog(context, ref),
                    icon: const Icon(Icons.create_new_folder),
                    label: const Text('New Folder'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
