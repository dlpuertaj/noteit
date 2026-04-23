import 'package:flutter_test/flutter_test.dart';
import 'package:notes/utils/constants.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:notes/data/app_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(path: inMemoryDatabasePath);
      await db.database;
    });

    tearDown(() async {
      await db.close();
    });

    test('creates notes table with correct columns', () async {
      final result = await (await db.database)
          .rawQuery('PRAGMA table_info(notes)');
      final columns = result.map((r) => r['name'] as String).toSet();
      expect(columns, containsAll({
        'id', 'title', 'body', 'folder_id', 'created_at', 'updated_at',
      }));
    });

    test('creates folders table with correct columns', () async {
      final result = await (await db.database)
          .rawQuery('PRAGMA table_info(folders)');
      final columns = result.map((r) => r['name'] as String).toSet();
      expect(columns, containsAll({
        'id', 'name', 'parent_id', 'depth', 'is_system', 'created_at',
      }));
    });

    test('creates settings table with correct column', () async {
      final result = await (await db.database)
          .rawQuery('PRAGMA table_info(settings)');
      final columns = result.map((r) => r['name'] as String).toSet();
      expect(columns, contains('max_folder_depth'));
    });

    test('seeds Inbox system folder with correct id', () async {
      final rows = await (await db.database)
          .query('folders', where: 'name = ?', whereArgs: ['Inbox']);
      expect(rows, hasLength(1));
      expect(rows.first['id'], kInboxFolderId);
      expect(rows.first['is_system'], 1);
      expect(rows.first['parent_id'], isNull);
      expect(rows.first['depth'], 1);
    });

    test('seeds Stash system folder with correct id', () async {
      final rows = await (await db.database)
          .query('folders', where: 'name = ?', whereArgs: ['Stash']);
      expect(rows, hasLength(1));
      expect(rows.first['id'], kStashFolderId);
      expect(rows.first['is_system'], 1);
      expect(rows.first['parent_id'], isNull);
      expect(rows.first['depth'], 1);
    });

    test('seeds settings row with default max_folder_depth of 2', () async {
      final rows = await (await db.database).query('settings');
      expect(rows, hasLength(1));
      expect(rows.first['max_folder_depth'], kDefaultMaxFolderDepth);
    });

    test('re-opening the same in-memory db does not duplicate system data',
        () async {
      final rows =
          await (await db.database).query('folders', where: 'is_system = 1');
      expect(rows, hasLength(2));

      final settingsRows = await (await db.database).query('settings');
      expect(settingsRows, hasLength(1));
    });
  });
}
