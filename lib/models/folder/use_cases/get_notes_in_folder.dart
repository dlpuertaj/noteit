import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';

class GetNotesInFolder {
  GetNotesInFolder(this._repo);

  final NoteRepository _repo;

  Future<List<Note>> execute(String folderId) => _repo.findByFolderId(folderId);
}
