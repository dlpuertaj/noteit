import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/delete_note.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('DeleteNote', () {
    late MockNoteRepository repo;
    late DeleteNote useCase;

    setUp(() {
      repo = MockNoteRepository();
      useCase = DeleteNote(repo);
      when(() => repo.delete(any())).thenAnswer((_) async {});
    });

    test('calls repository.delete with the correct id', () async {
      await useCase.execute('note-1');
      verify(() => repo.delete('note-1')).called(1);
    });
  });
}
