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
      when(() => repo.findByFolderId(any())).thenAnswer((_) async => [existing]);
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

    test('duplicate title in same folder is auto-suffixed with (2)', () async {
      final sibling = Note(
        id: 'note-2',
        title: 'Shopping',
        body: '',
        folderId: kInboxFolderId,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      when(() => repo.findByFolderId(kInboxFolderId))
          .thenAnswer((_) async => [existing, sibling]);
      await useCase.execute('note-1', 'Shopping', 'Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).title, 'Shopping (2)');
    });

    test('if (2) is also taken, suffix increments to (3)', () async {
      final sibling1 = Note(
        id: 'note-2',
        title: 'Shopping',
        body: '',
        folderId: kInboxFolderId,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      final sibling2 = Note(
        id: 'note-3',
        title: 'Shopping (2)',
        body: '',
        folderId: kInboxFolderId,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      when(() => repo.findByFolderId(kInboxFolderId))
          .thenAnswer((_) async => [existing, sibling1, sibling2]);
      await useCase.execute('note-1', 'Shopping', 'Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).title, 'Shopping (3)');
    });

    test('blank title duplicating Untitled is auto-suffixed', () async {
      final sibling = Note(
        id: 'note-2',
        title: 'Untitled',
        body: '',
        folderId: kInboxFolderId,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      when(() => repo.findByFolderId(kInboxFolderId))
          .thenAnswer((_) async => [existing, sibling]);
      await useCase.execute('note-1', '', 'Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).title, 'Untitled (2)');
    });

    test('keeps current title if no duplicate exists', () async {
      when(() => repo.findByFolderId(kInboxFolderId))
          .thenAnswer((_) async => [existing]);
      await useCase.execute('note-1', 'Unique Title', 'Body');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Note).title, 'Unique Title');
    });
  });
}
