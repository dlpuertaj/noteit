import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';

class SearchNotesByTitle {
  SearchNotesByTitle(this._repo);

  final NoteRepository _repo;

  Future<List<Note>> execute(String query) {
    if (query.trim().isEmpty) return Future.value([]);
    return _repo.searchByTitle(query);
  }
}
