import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/search_notes_by_title.dart';
import 'package:notes/utils/constants.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('SearchNotesByTitle', () {
    late MockNoteRepository repo;
    late SearchNotesByTitle useCase;

    final results = [
      Note(id: '1', title: 'Flutter Tips', body: '', folderId: kInboxFolderId,
          createdAt: DateTime(2026), updatedAt: DateTime(2026)),
    ];

    setUp(() {
      repo = MockNoteRepository();
      useCase = SearchNotesByTitle(repo);
    });

    test('empty query returns empty list without calling repository', () async {
      final result = await useCase.execute('');
      expect(result, isEmpty);
      verifyNever(() => repo.searchByTitle(any()));
    });

    test('blank query returns empty list without calling repository', () async {
      final result = await useCase.execute('   ');
      expect(result, isEmpty);
      verifyNever(() => repo.searchByTitle(any()));
    });

    test('non-empty query delegates to repository.searchByTitle', () async {
      when(() => repo.searchByTitle('flutter')).thenAnswer((_) async => results);
      final result = await useCase.execute('flutter');
      expect(result, results);
      verify(() => repo.searchByTitle('flutter')).called(1);
    });
  });
}
