import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/edit_note.dart';
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

  group('EditNote', () {
    late MockNoteRepository repo;
    late EditNote useCase;

    final existing = Note(
      id: 'note-1',
      title: 'Old Title',
      body: 'Old Body',
      folderId: kInboxFolderId,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    setUp(() {
      repo = MockNoteRepository();
      useCase = EditNote(repo);
      when(() => repo.findById('note-1')).thenAnswer((_) async => existing);
      when(() => repo.update(any())).thenAnswer((_) async {});
    });

    test('title is updated', () async {
      await useCase.execute('note-1', 'New Title', 'Old Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).title, 'New Title');
    });

    test('body is updated', () async {
      await useCase.execute('note-1', 'Old Title', 'New Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).body, 'New Body');
    });

    test('updatedAt is set to a time after createdAt', () async {
      await useCase.execute('note-1', 'Title', 'Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      final updated = captured.first as Note;
      expect(updated.updatedAt.isAfter(existing.createdAt) ||
          updated.updatedAt.isAtSameMomentAs(existing.createdAt), isTrue);
    });

    test('blank title defaults to Untitled', () async {
      await useCase.execute('note-1', '   ', 'Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).title, 'Untitled');
    });
  });
}
