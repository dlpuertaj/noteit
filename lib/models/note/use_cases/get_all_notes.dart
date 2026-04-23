import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';

class GetAllNotes {
  GetAllNotes(this._repo);

  final NoteRepository _repo;

  Future<List<Note>> execute() => _repo.findAll();
}
