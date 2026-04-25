import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/use_cases/search_notes_by_title.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';

final _searchNotesByTitleProvider = Provider<SearchNotesByTitle>((ref) {
  return SearchNotesByTitle(ref.read(noteRepositoryProvider));
});

class SearchState {
  const SearchState({this.query = '', this.results = const []});

  final String query;
  final List<Note> results;
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  Future<void> setQuery(String query) async {
    final results =
        await ref.read(_searchNotesByTitleProvider).execute(query);
    state = SearchState(query: query, results: results);
  }

  void clear() => state = const SearchState();
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
