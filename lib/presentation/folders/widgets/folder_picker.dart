import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/presentation/folders/providers/folder_provider.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';

class FolderPicker extends ConsumerWidget {
  const FolderPicker({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(folderProvider).folders;

    return Scaffold(
      appBar: AppBar(title: const Text('Move to folder')),
      body: ListView(
        children: folders
            .map((folder) => ListTile(
                  title: Text(folder.name),
                  onTap: () async {
                    await ref
                        .read(noteProvider.notifier)
                        .moveNoteToFolder(noteId, folder.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
    );
  }
}
