import 'package:notes/data/app_database.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';

class SqfliteFolderRepository implements FolderRepository {
  SqfliteFolderRepository(this._appDb);

  final AppDatabase _appDb;

  @override
  Future<void> insert(Folder folder) async {
    final db = await _appDb.database;
    await db.insert('folders', _toRow(folder));
  }

  @override
  Future<Folder?> findById(String id) async {
    final db = await _appDb.database;
    final rows = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<List<Folder>> findAll() async {
    final db = await _appDb.database;
    final rows = await db.query('folders');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> update(Folder folder) async {
    final db = await _appDb.database;
    await db.update(
      'folders',
      _toRow(folder),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDb.database;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(Folder folder) => {
        'id': folder.id,
        'name': folder.name,
        'parent_id': folder.parentId,
        'depth': folder.depth,
        'is_system': folder.isSystem ? 1 : 0,
        'created_at': folder.createdAt.millisecondsSinceEpoch,
      };

  Folder _fromRow(Map<String, Object?> row) => Folder(
        id: row['id'] as String,
        name: row['name'] as String,
        parentId: row['parent_id'] as String?,
        depth: row['depth'] as int,
        isSystem: (row['is_system'] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
}
