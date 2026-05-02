import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/models/folder/use_cases/create_folder.dart';

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

  group('CreateFolder', () {
    late MockFolderRepository repo;
    late CreateFolder useCase;

    final parentFolder = Folder(
      id: 'parent-1',
      name: 'Work',
      parentId: null,
      depth: 1,
      isSystem: false,
      createdAt: DateTime(2026),
    );

    setUp(() {
      repo = MockFolderRepository();
      useCase = CreateFolder(repo);
      when(() => repo.insert(any())).thenAnswer((_) async {});
      when(() => repo.findById('parent-1')).thenAnswer((_) async => parentFolder);
      when(() => repo.findAll()).thenAnswer((_) async => [parentFolder]);
    });

    test('root folder has depth 1 and parentId null', () async {
      final folder = await useCase.execute('Personal', parentId: null, maxFolderDepth: 2);
      expect(folder.depth, 1);
      expect(folder.parentId, isNull);
    });

    test('subfolder has depth 2 and correct parentId', () async {
      final folder = await useCase.execute('Projects', parentId: 'parent-1', maxFolderDepth: 2);
      expect(folder.depth, 2);
      expect(folder.parentId, 'parent-1');
    });

    test('created folder is not a system folder', () async {
      final folder = await useCase.execute('Personal', parentId: null, maxFolderDepth: 2);
      expect(folder.isSystem, isFalse);
    });

    test('generated id is non-empty', () async {
      final folder = await useCase.execute('Personal', parentId: null, maxFolderDepth: 2);
      expect(folder.id, isNotEmpty);
    });

    test('throws ArgumentError when name is "Inbox"', () async {
      expect(
        () => useCase.execute('Inbox', parentId: null, maxFolderDepth: 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when name is "inbox" (case-insensitive)', () async {
      expect(
        () => useCase.execute('inbox', parentId: null, maxFolderDepth: 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when name is "Stash"', () async {
      expect(
        () => useCase.execute('Stash', parentId: null, maxFolderDepth: 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when resulting depth exceeds maxFolderDepth', () async {
      expect(
        () => useCase.execute('Deep', parentId: 'parent-1', maxFolderDepth: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when a sibling folder has the same name', () async {
      final sibling = Folder(
        id: 'sibling-1',
        name: 'Personal',
        parentId: null,
        depth: 1,
        isSystem: false,
        createdAt: DateTime(2026),
      );
      when(() => repo.findAll()).thenAnswer((_) async => [parentFolder, sibling]);
      expect(
        () => useCase.execute('Personal', parentId: null, maxFolderDepth: 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('sibling name check is case-insensitive', () async {
      final sibling = Folder(
        id: 'sibling-1',
        name: 'Personal',
        parentId: null,
        depth: 1,
        isSystem: false,
        createdAt: DateTime(2026),
      );
      when(() => repo.findAll()).thenAnswer((_) async => [parentFolder, sibling]);
      expect(
        () => useCase.execute('PERSONAL', parentId: null, maxFolderDepth: 2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('same name allowed under different parent', () async {
      final sibling = Folder(
        id: 'sibling-1',
        name: 'Personal',
        parentId: 'parent-1',
        depth: 2,
        isSystem: false,
        createdAt: DateTime(2026),
      );
      when(() => repo.findAll()).thenAnswer((_) async => [parentFolder, sibling]);
      final created = await useCase.execute('Personal', parentId: null, maxFolderDepth: 2);
      expect(created.name, 'Personal');
    });
  });
}
