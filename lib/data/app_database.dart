import 'package:notes/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({this.path});

  final String? path;
  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _open() async {
    final dbPath = path ?? await _productionPath();
    return openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<String> _productionPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/notes.db';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        folder_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        parent_id TEXT,
        depth INTEGER NOT NULL,
        is_system INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        max_folder_depth INTEGER NOT NULL
      )
    ''');

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('folders', {
      'id': kInboxFolderId,
      'name': 'Inbox',
      'parent_id': null,
      'depth': 1,
      'is_system': 1,
      'created_at': now,
    });

    await db.insert('folders', {
      'id': kStashFolderId,
      'name': 'Stash',
      'parent_id': null,
      'depth': 1,
      'is_system': 1,
      'created_at': now,
    });

    await db.insert('settings', {'max_folder_depth': kDefaultMaxFolderDepth});
  }
}
