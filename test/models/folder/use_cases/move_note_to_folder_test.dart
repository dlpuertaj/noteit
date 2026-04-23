import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/folder/use_cases/move_note_to_folder.dart';
import 'package:notes/utils/constants.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  setUpAll(() => registerFallbackValue(
        Note(
          id: '', title: '', body: '', folderId: '',
          createdAt: DateTime(2026), updatedAt: DateTime(2026),
        ),
      ));

  group('MoveNoteToFolder', () {
    late MockNoteRepository repo;
    late MoveNoteToFolder useCase;

    final note = Note(
      id: 'note-1', title: 'Title', body: '', folderId: kInboxFolderId,
      createdAt: DateTime(2026), updatedAt: DateTime(2026),
    );

    setUp(() {
      repo = MockNoteRepository();
      useCase = MoveNoteToFolder(repo);
      when(() => repo.findById('note-1')).thenAnswer((_) async => note);
      when(() => repo.update(any())).thenAnswer((_) async {});
    });

    test('updates note folderId to target folder', () async {
      await useCase.execute('note-1', kStashFolderId);
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).folderId, kStashFolderId);
    });

    test('can move to Inbox', () async {
      await useCase.execute('note-1', kInboxFolderId);
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).folderId, kInboxFolderId);
    });
  });
}
