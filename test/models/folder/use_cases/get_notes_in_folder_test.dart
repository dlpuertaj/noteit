import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/folder/use_cases/get_notes_in_folder.dart';
import 'package:notes/utils/constants.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('GetNotesInFolder', () {
    late MockNoteRepository repo;
    late GetNotesInFolder useCase;

    setUp(() {
      repo = MockNoteRepository();
      useCase = GetNotesInFolder(repo);
    });

    test('delegates to repository.findByFolderId', () async {
      final notes = [
        Note(id: '1', title: 'A', body: '', folderId: kInboxFolderId,
            createdAt: DateTime(2026), updatedAt: DateTime(2026)),
      ];
      when(() => repo.findByFolderId(kInboxFolderId)).thenAnswer((_) async => notes);
      final result = await useCase.execute(kInboxFolderId);
      expect(result, notes);
      verify(() => repo.findByFolderId(kInboxFolderId)).called(1);
    });
  });
}
