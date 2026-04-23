import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/models/folder/use_cases/delete_folder.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/utils/constants.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Folder(
      id: '', name: '', parentId: null, depth: 1,
      isSystem: false, createdAt: DateTime(2026),
    ));
    registerFallbackValue(Note(
      id: '', title: '', body: '', folderId: '',
      createdAt: DateTime(2026), updatedAt: DateTime(2026),
    ));
    registerFallbackValue(<String>[]);
  });

  group('DeleteFolder', () {
    late MockFolderRepository folderRepo;
    late MockNoteRepository noteRepo;
    late DeleteFolder useCase;

    final userFolder = Folder(
      id: 'folder-1', name: 'Work', parentId: null,
      depth: 1, isSystem: false, createdAt: DateTime(2026),
    );
    final systemFolder = Folder(
      id: kInboxFolderId, name: 'Inbox', parentId: null,
      depth: 1, isSystem: true, createdAt: DateTime(2026),
    );
    final note = Note(
      id: 'note-1', title: 'N', body: '', folderId: 'folder-1',
      createdAt: DateTime(2026), updatedAt: DateTime(2026),
    );

    setUp(() {
      folderRepo = MockFolderRepository();
      noteRepo = MockNoteRepository();
      useCase = DeleteFolder(folderRepo, noteRepo);
      when(() => folderRepo.delete(any())).thenAnswer((_) async {});
      when(() => noteRepo.deleteAllInFolder(any())).thenAnswer((_) async {});
      when(() => noteRepo.moveAllToFolder(any(), any())).thenAnswer((_) async {});
    });

    test('empty folder is deleted immediately with no note operations', () async {
      when(() => folderRepo.findById('folder-1')).thenAnswer((_) async => userFolder);
      when(() => folderRepo.findAll()).thenAnswer((_) async => [userFolder]);
      when(() => noteRepo.findByFolderId('folder-1')).thenAnswer((_) async => []);

      await useCase.execute('folder-1', DeleteFolderAction.deletePermanently);

      verifyNever(() => noteRepo.deleteAllInFolder(any()));
      verifyNever(() => noteRepo.moveAllToFolder(any(), any()));
      verify(() => folderRepo.delete('folder-1')).called(1);
    });

    test('moveToStash moves all notes then deletes the folder', () async {
      when(() => folderRepo.findById('folder-1')).thenAnswer((_) async => userFolder);
      when(() => folderRepo.findAll()).thenAnswer((_) async => [userFolder]);
      when(() => noteRepo.findByFolderId('folder-1')).thenAnswer((_) async => [note]);

      await useCase.execute('folder-1', DeleteFolderAction.moveToStash);

      verify(() => noteRepo.moveAllToFolder(['note-1'], kStashFolderId)).called(1);
      verify(() => folderRepo.delete('folder-1')).called(1);
    });

    test('deletePermanently removes all notes then deletes the folder', () async {
      when(() => folderRepo.findById('folder-1')).thenAnswer((_) async => userFolder);
      when(() => folderRepo.findAll()).thenAnswer((_) async => [userFolder]);
      when(() => noteRepo.findByFolderId('folder-1')).thenAnswer((_) async => [note]);

      await useCase.execute('folder-1', DeleteFolderAction.deletePermanently);

      verify(() => noteRepo.deleteAllInFolder('folder-1')).called(1);
      verify(() => folderRepo.delete('folder-1')).called(1);
    });

    test('throws ArgumentError when folder is a system folder', () {
      when(() => folderRepo.findById(kInboxFolderId)).thenAnswer((_) async => systemFolder);
      expect(
        () => useCase.execute(kInboxFolderId, DeleteFolderAction.deletePermanently),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('notes in subfolders are also moved when moveToStash is chosen', () async {
      final subfolder = Folder(
        id: 'sub-1', name: 'Sub', parentId: 'folder-1',
        depth: 2, isSystem: false, createdAt: DateTime(2026),
      );
      final subNote = note.copyWith(id: 'note-2', folderId: 'sub-1');

      when(() => folderRepo.findById('folder-1')).thenAnswer((_) async => userFolder);
      when(() => folderRepo.findAll()).thenAnswer((_) async => [userFolder, subfolder]);
      when(() => noteRepo.findByFolderId('folder-1')).thenAnswer((_) async => []);
      when(() => noteRepo.findByFolderId('sub-1')).thenAnswer((_) async => [subNote]);

      await useCase.execute('folder-1', DeleteFolderAction.moveToStash);

      verify(() => noteRepo.moveAllToFolder(['note-2'], kStashFolderId)).called(1);
      verify(() => folderRepo.delete('sub-1')).called(1);
      verify(() => folderRepo.delete('folder-1')).called(1);
    });
  });
}
