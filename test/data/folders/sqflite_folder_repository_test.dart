import 'package:flutter_test/flutter_test.dart';
import 'package:notes/data/app_database.dart';
import 'package:notes/data/folders/sqflite_folder_repository.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/utils/constants.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqfliteFolderRepository', () {
    late AppDatabase appDb;
    late SqfliteFolderRepository repo;

    final userFolder = Folder(
      id: 'folder-1',
      name: 'Work',
      parentId: null,
      depth: 1,
      isSystem: false,
      createdAt: DateTime(2026, 1, 1),
    );

    setUp(() async {
      appDb = AppDatabase(path: inMemoryDatabasePath);
      await appDb.database;
      repo = SqfliteFolderRepository(appDb);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('insert then findById returns the folder', () async {
      await repo.insert(userFolder);
      final found = await repo.findById('folder-1');
      expect(found, isNotNull);
      expect(found!.id, 'folder-1');
      expect(found.name, 'Work');
      expect(found.parentId, isNull);
      expect(found.depth, 1);
      expect(found.isSystem, false);
    });

    test('findById returns null when folder does not exist', () async {
      final found = await repo.findById('non-existent');
      expect(found, isNull);
    });

    test('findAll includes system folders seeded by AppDatabase', () async {
      final all = await repo.findAll();
      final names = all.map((f) => f.name).toSet();
      expect(names, containsAll({'Inbox', 'Stash'}));
    });

    test('findAll returns user folders alongside system folders', () async {
      await repo.insert(userFolder);
      final all = await repo.findAll();
      expect(all.length, greaterThanOrEqualTo(3));
      expect(all.any((f) => f.id == 'folder-1'), isTrue);
    });

    test('update persists name change', () async {
      await repo.insert(userFolder);
      final renamed = userFolder.copyWith(name: 'Personal');
      await repo.update(renamed);
      final found = await repo.findById('folder-1');
      expect(found!.name, 'Personal');
    });

    test('delete removes a non-system folder', () async {
      await repo.insert(userFolder);
      await repo.delete('folder-1');
      final found = await repo.findById('folder-1');
      expect(found, isNull);
    });

    test('system folder ids are the expected constants', () async {
      final inbox = await repo.findById(kInboxFolderId);
      final stash = await repo.findById(kStashFolderId);
      expect(inbox, isNotNull);
      expect(stash, isNotNull);
      expect(inbox!.isSystem, isTrue);
      expect(stash!.isSystem, isTrue);
    });
  });
}
