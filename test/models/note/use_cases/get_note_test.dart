import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/get_note.dart';
import 'package:notes/utils/constants.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('GetNote', () {
    late MockNoteRepository repo;
    late GetNote useCase;

    final note = Note(
      id: 'note-1',
      title: 'Title',
      body: 'Body',
      folderId: kInboxFolderId,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    setUp(() {
      repo = MockNoteRepository();
      useCase = GetNote(repo);
    });

    test('returns note when found', () async {
      when(() => repo.findById('note-1')).thenAnswer((_) async => note);
      final result = await useCase.execute('note-1');
      expect(result, note);
    });

    test('returns null when not found', () async {
      when(() => repo.findById('missing')).thenAnswer((_) async => null);
      final result = await useCase.execute('missing');
      expect(result, isNull);
    });
  });
}
