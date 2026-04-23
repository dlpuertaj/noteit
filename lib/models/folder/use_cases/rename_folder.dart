import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/utils/constants.dart';

class RenameFolder {
  RenameFolder(this._repo);

  final FolderRepository _repo;

  Future<void> execute(String folderId, String newName) async {
    final folder = await _repo.findById(folderId);
    if (folder == null) throw ArgumentError('Folder not found.');
    if (folder.isSystem) throw ArgumentError('System folders cannot be renamed.');

    final trimmed = newName.trim();
    if (kReservedFolderNames
        .any((r) => r.toLowerCase() == trimmed.toLowerCase())) {
      throw ArgumentError('This name is reserved.');
    }

    await _repo.update(folder.copyWith(name: trimmed));
  }
}
