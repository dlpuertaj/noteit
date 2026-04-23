import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/models/folder/use_cases/get_folders.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  group('GetFolders', () {
    late MockFolderRepository repo;
    late GetFolders useCase;

    setUp(() {
      repo = MockFolderRepository();
      useCase = GetFolders(repo);
    });

    test('delegates to repository.findAll', () async {
      final folders = [
        Folder(id: '1', name: 'Inbox', parentId: null, depth: 1,
            isSystem: true, createdAt: DateTime(2026)),
      ];
      when(() => repo.findAll()).thenAnswer((_) async => folders);
      final result = await useCase.execute();
      expect(result, folders);
      verify(() => repo.findAll()).called(1);
    });
  });
}
