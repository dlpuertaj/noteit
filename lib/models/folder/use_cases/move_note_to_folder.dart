import 'package:notes/models/note/note_repository.dart';

class MoveNoteToFolder {
  MoveNoteToFolder(this._repo);

  final NoteRepository _repo;

  Future<void> execute(String noteId, String targetFolderId) async {
    final note = await _repo.findById(noteId);
    if (note == null) return;
    await _repo.update(note.copyWith(folderId: targetFolderId));
  }
}
