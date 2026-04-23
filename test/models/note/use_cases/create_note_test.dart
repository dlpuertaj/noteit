import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/create_note.dart';
import 'package:notes/utils/constants.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  setUpAll(() => registerFallbackValue(
        Note(
          id: '',
          title: '',
          body: '',
          folderId: '',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ));

  group('CreateNote', () {
    late MockNoteRepository repo;
    late CreateNote useCase;

    setUp(() {
      repo = MockNoteRepository();
      useCase = CreateNote(repo);
      when(() => repo.insert(any())).thenAnswer((_) async {});
    });

    test('generated id is non-empty', () async {
      final note = await useCase.execute('Title', 'Body');
      expect(note.id, isNotEmpty);
    });

    test('title and body match inputs', () async {
      final note = await useCase.execute('My Title', 'My Body');
      expect(note.title, 'My Title');
      expect(note.body, 'My Body');
    });

    test('folderId matches input when provided', () async {
      final note = await useCase.execute('Title', 'Body', folderId: 'folder-x');
      expect(note.folderId, 'folder-x');
    });

    test('createdAt equals updatedAt on creation', () async {
      final note = await useCase.execute('Title', 'Body');
      expect(note.createdAt, note.updatedAt);
    });

    test('defaults folderId to Inbox when not provided', () async {
      final note = await useCase.execute('Title', 'Body');
      expect(note.folderId, kInboxFolderId);
    });
  });
}
