import 'package:flutter_test/flutter_test.dart';
import 'package:notes/data/app_database.dart';
import 'package:notes/data/notes/sqflite_note_repository.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/utils/constants.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqfliteNoteRepository', () {
    late AppDatabase appDb;
    late SqfliteNoteRepository repo;

    final baseNote = Note(
      id: 'note-1',
      title: 'Test Note',
      body: 'Some body',
      folderId: kInboxFolderId,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    setUp(() async {
      appDb = AppDatabase(path: inMemoryDatabasePath);
      await appDb.database;
      repo = SqfliteNoteRepository(appDb);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('insert then findById returns the note', () async {
      await repo.insert(baseNote);
      final found = await repo.findById('note-1');
      expect(found, isNotNull);
      expect(found!.id, 'note-1');
      expect(found.title, 'Test Note');
      expect(found.body, 'Some body');
      expect(found.folderId, kInboxFolderId);
    });

    test('findById returns null when note does not exist', () async {
      final found = await repo.findById('non-existent');
      expect(found, isNull);
    });

    test('findAll returns all inserted notes', () async {
      final note2 = baseNote.copyWith(id: 'note-2', title: 'Second');
      await repo.insert(baseNote);
      await repo.insert(note2);
      final all = await repo.findAll();
      expect(all, hasLength(2));
    });

    test('findByFolderId returns only notes in that folder', () async {
      final otherNote = baseNote.copyWith(id: 'note-2', folderId: kStashFolderId);
      await repo.insert(baseNote);
      await repo.insert(otherNote);
      final results = await repo.findByFolderId(kInboxFolderId);
      expect(results, hasLength(1));
      expect(results.first.id, 'note-1');
    });

    test('searchByTitle returns partial case-insensitive matches', () async {
      final note2 = baseNote.copyWith(id: 'note-2', title: 'Another note');
      await repo.insert(baseNote);
      await repo.insert(note2);
      final results = await repo.searchByTitle('test');
      expect(results, hasLength(1));
      expect(results.first.id, 'note-1');
    });

    test('searchByTitle returns empty list for empty query', () async {
      await repo.insert(baseNote);
      final results = await repo.searchByTitle('');
      expect(results, isEmpty);
    });

    test('update persists changes', () async {
      await repo.insert(baseNote);
      final updated = baseNote.copyWith(
        title: 'Updated Title',
        body: 'Updated body',
        updatedAt: DateTime(2026, 6, 1),
      );
      await repo.update(updated);
      final found = await repo.findById('note-1');
      expect(found!.title, 'Updated Title');
      expect(found.body, 'Updated body');
    });

    test('delete removes the note', () async {
      await repo.insert(baseNote);
      await repo.delete('note-1');
      final found = await repo.findById('note-1');
      expect(found, isNull);
    });

    test('deleteAllInFolder removes all notes in that folder', () async {
      final note2 = baseNote.copyWith(id: 'note-2');
      final note3 = baseNote.copyWith(id: 'note-3', folderId: kStashFolderId);
      await repo.insert(baseNote);
      await repo.insert(note2);
      await repo.insert(note3);
      await repo.deleteAllInFolder(kInboxFolderId);
      final remaining = await repo.findAll();
      expect(remaining, hasLength(1));
      expect(remaining.first.id, 'note-3');
    });

    test('moveAllToFolder updates folderId for all given ids', () async {
      final note2 = baseNote.copyWith(id: 'note-2');
      await repo.insert(baseNote);
      await repo.insert(note2);
      await repo.moveAllToFolder(['note-1', 'note-2'], kStashFolderId);
      final inStash = await repo.findByFolderId(kStashFolderId);
      expect(inStash, hasLength(2));
    });
  });
}
