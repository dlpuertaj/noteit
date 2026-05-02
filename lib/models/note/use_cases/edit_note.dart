import 'package:notes/models/note/note_repository.dart';

class EditNote {
  EditNote(this._repo);

  final NoteRepository _repo;

  Future<void> execute(String noteId, String title, String body) async {
    final note = await _repo.findById(noteId);
    if (note == null) return;
    final trimmed = title.trim();
    final base = trimmed.isEmpty ? 'Untitled' : trimmed;

    final siblings = await _repo.findByFolderId(note.folderId);
    final taken = siblings
        .where((n) => n.id != noteId)
        .map((n) => n.title)
        .toSet();

    String resolved = base;
    int suffix = 2;
    while (taken.contains(resolved)) {
      resolved = '$base ($suffix)';
      suffix++;
    }

    await _repo.update(note.copyWith(
      title: resolved,
      body: body,
      updatedAt: DateTime.now(),
    ));
  }
}
