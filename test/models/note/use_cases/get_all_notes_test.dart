import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/get_all_notes.dart';
import 'package:notes/utils/constants.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('GetAllNotes', () {
    late MockNoteRepository repo;
    late GetAllNotes useCase;

    setUp(() {
      repo = MockNoteRepository();
      useCase = GetAllNotes(repo);
    });

    test('returns empty list when no notes exist', () async {
      when(() => repo.findAll()).thenAnswer((_) async => []);
      final result = await useCase.execute();
      expect(result, isEmpty);
    });

    test('returns all notes', () async {
      final notes = [
        Note(id: '1', title: 'A', body: '', folderId: kInboxFolderId,
            createdAt: DateTime(2026), updatedAt: DateTime(2026)),
        Note(id: '2', title: 'B', body: '', folderId: kInboxFolderId,
            createdAt: DateTime(2026), updatedAt: DateTime(2026)),
      ];
      when(() => repo.findAll()).thenAnswer((_) async => notes);
      final result = await useCase.execute();
      expect(result, hasLength(2));
    });
  });
}
