import 'package:notes/data/app_database.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';

class SqfliteNoteRepository implements NoteRepository {
  SqfliteNoteRepository(this._appDb);

  final AppDatabase _appDb;

  @override
  Future<void> insert(Note note) async {
    final db = await _appDb.database;
    await db.insert('notes', _toRow(note));
  }

  @override
  Future<Note?> findById(String id) async {
    final db = await _appDb.database;
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<List<Note>> findAll() async {
    final db = await _appDb.database;
    final rows = await db.query('notes');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Note>> findByFolderId(String folderId) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'notes',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Note>> searchByTitle(String query) async {
    if (query.isEmpty) return [];
    final db = await _appDb.database;
    final rows = await db.query(
      'notes',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> update(Note note) async {
    final db = await _appDb.database;
    await db.update(
      'notes',
      _toRow(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDb.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAllInFolder(String folderId) async {
    final db = await _appDb.database;
    await db.delete('notes', where: 'folder_id = ?', whereArgs: [folderId]);
  }

  @override
  Future<void> moveAllToFolder(List<String> ids, String targetFolderId) async {
    if (ids.isEmpty) return;
    final db = await _appDb.database;
    final placeholders = ids.map((_) => '?').join(', ');
    await db.rawUpdate(
      'UPDATE notes SET folder_id = ? WHERE id IN ($placeholders)',
      [targetFolderId, ...ids],
    );
  }

  Map<String, Object?> _toRow(Note note) => {
        'id': note.id,
        'title': note.title,
        'body': note.body,
        'folder_id': note.folderId,
        'created_at': note.createdAt.millisecondsSinceEpoch,
        'updated_at': note.updatedAt.millisecondsSinceEpoch,
      };

  Note _fromRow(Map<String, Object?> row) => Note(
        id: row['id'] as String,
        title: row['title'] as String,
        body: row['body'] as String,
        folderId: row['folder_id'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      );
}
