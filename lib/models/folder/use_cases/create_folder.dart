import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/utils/constants.dart';
import 'package:uuid/uuid.dart';

class CreateFolder {
  CreateFolder(this._repo);

  final FolderRepository _repo;

  Future<Folder> execute(
    String name, {
    required String? parentId,
    required int maxFolderDepth,
  }) async {
    final trimmed = name.trim();
    if (kReservedFolderNames
        .any((r) => r.toLowerCase() == trimmed.toLowerCase())) {
      throw ArgumentError('This name is reserved.');
    }

    int depth = 1;
    if (parentId != null) {
      final parent = await _repo.findById(parentId);
      if (parent == null) throw ArgumentError('Parent folder not found.');
      depth = parent.depth + 1;
    }

    if (depth > maxFolderDepth) {
      throw ArgumentError('Maximum folder depth exceeded.');
    }

    final all = await _repo.findAll();
    final hasDuplicate = all.any((f) =>
        f.parentId == parentId &&
        f.name.toLowerCase() == trimmed.toLowerCase());
    if (hasDuplicate) {
      throw ArgumentError('A folder with this name already exists here.');
    }

    final folder = Folder(
      id: const Uuid().v4(),
      name: trimmed,
      parentId: parentId,
      depth: depth,
      isSystem: false,
      createdAt: DateTime.now(),
    );
    await _repo.insert(folder);
    return folder;
  }
}
