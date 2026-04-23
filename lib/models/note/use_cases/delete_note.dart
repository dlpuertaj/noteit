import 'package:notes/models/note/note_repository.dart';

class DeleteNote {
  DeleteNote(this._repo);

  final NoteRepository _repo;

  Future<void> execute(String noteId) => _repo.delete(noteId);
}
