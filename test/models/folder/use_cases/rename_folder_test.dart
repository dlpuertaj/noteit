import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/models/folder/use_cases/rename_folder.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  setUpAll(() => registerFallbackValue(
        Folder(
          id: '',
          name: '',
          parentId: null,
          depth: 1,
          isSystem: false,
          createdAt: DateTime(2026),
        ),
      ));

  group('RenameFolder', () {
    late MockFolderRepository repo;
    late RenameFolder useCase;

    final userFolder = Folder(
      id: 'folder-1',
      name: 'Work',
      parentId: null,
      depth: 1,
      isSystem: false,
      createdAt: DateTime(2026),
    );

    final systemFolder = Folder(
      id: 'inbox-id',
      name: 'Inbox',
      parentId: null,
      depth: 1,
      isSystem: true,
      createdAt: DateTime(2026),
    );

    setUp(() {
      repo = MockFolderRepository();
      useCase = RenameFolder(repo);
      when(() => repo.update(any())).thenAnswer((_) async {});
      when(() => repo.findById('folder-1')).thenAnswer((_) async => userFolder);
      when(() => repo.findById('inbox-id')).thenAnswer((_) async => systemFolder);
      when(() => repo.findAll()).thenAnswer((_) async => [userFolder, systemFolder]);
    });

    test('renames a user folder successfully', () async {
      await useCase.execute('folder-1', 'Personal');
      final captured = verify(() => repo.update(captureAny())).captured;
      expect((captured.first as Folder).name, 'Personal');
    });

    test('throws ArgumentError when new name is "Inbox"', () {
      expect(
        () => useCase.execute('folder-1', 'Inbox'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when new name is "Stash"', () {
      expect(
        () => useCase.execute('folder-1', 'Stash'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when folder is a system folder', () {
      expect(
        () => useCase.execute('inbox-id', 'NewName'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when a sibling folder has the new name', () async {
      final sibling = Folder(
        id: 'sibling-1',
        name: 'Personal',
        parentId: null,
        depth: 1,
        isSystem: false,
        createdAt: DateTime(2026),
      );
      when(() => repo.findAll())
          .thenAnswer((_) async => [userFolder, systemFolder, sibling]);
      expect(
        () => useCase.execute('folder-1', 'Personal'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('renaming to its own current name is allowed', () async {
      // self-id is excluded from the duplicate check
      await useCase.execute('folder-1', 'Work');
      verify(() => repo.update(any())).called(1);
    });
  });
}
