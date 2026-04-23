import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';

class GetNote {
  GetNote(this._repo);

  final NoteRepository _repo;

  Future<Note?> execute(String noteId) => _repo.findById(noteId);
}
