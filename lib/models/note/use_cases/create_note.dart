import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/utils/constants.dart';
import 'package:uuid/uuid.dart';

class CreateNote {
  CreateNote(this._repo);

  final NoteRepository _repo;

  Future<Note> execute(String title, String body, {String? folderId}) async {
    final now = DateTime.now();
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      body: body,
      folderId: folderId ?? kInboxFolderId,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.insert(note);
    return note;
  }
}
