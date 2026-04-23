import 'package:notes/models/note/note.dart';

abstract class NoteRepository {
  Future<void> insert(Note note);
  Future<Note?> findById(String id);
  Future<List<Note>> findAll();
  Future<List<Note>> findByFolderId(String folderId);
  Future<List<Note>> searchByTitle(String query);
  Future<void> update(Note note);
  Future<void> delete(String id);
  Future<void> deleteAllInFolder(String folderId);
  Future<void> moveAllToFolder(List<String> ids, String targetFolderId);
}
