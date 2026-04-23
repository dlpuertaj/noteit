import 'package:notes/models/note/note_repository.dart';

class EditNote {
  EditNote(this._repo);

  final NoteRepository _repo;

  Future<void> execute(String noteId, String title, String body) async {
    final note = await _repo.findById(noteId);
    if (note == null) return;
    final trimmed = title.trim();
    await _repo.update(note.copyWith(
      title: trimmed.isEmpty ? 'Untitled' : trimmed,
      body: body,
      updatedAt: DateTime.now(),
    ));
  }
}
