import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/folders/providers/folder_provider.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/presentation/search/providers/search_provider.dart';
import 'package:notes/presentation/search/widgets/search_bar.dart';
import 'package:notes/presentation/search/widgets/search_result_item.dart';

class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final folders = ref.watch(folderProvider).folders;

    Widget body;
    if (searchState.query.isEmpty) {
      body = const SizedBox.shrink();
    } else if (searchState.results.isEmpty) {
      body = const Center(child: Text('No notes found.'));
    } else {
      body = ListView(
        children: searchState.results.map((note) {
          final folder =
              folders.where((f) => f.id == note.folderId).firstOrNull;
          return SearchResultItem(
            title: note.title,
            folderName: folder?.name ?? '',
            onTap: () async {
              await ref.read(noteProvider.notifier).loadNote(note.id);
              if (context.mounted) context.go('/');
            },
          );
        }).toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: NoteSearchBar(
              onChanged: (q) =>
                  ref.read(searchProvider.notifier).setQuery(q),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
