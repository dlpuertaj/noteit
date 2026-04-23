import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/utils/constants.dart';

enum DeleteFolderAction { moveToStash, deletePermanently }

class DeleteFolder {
  DeleteFolder(this._folderRepo, this._noteRepo);

  final FolderRepository _folderRepo;
  final NoteRepository _noteRepo;

  Future<void> execute(String folderId, DeleteFolderAction action) async {
    final folder = await _folderRepo.findById(folderId);
    if (folder == null) throw ArgumentError('Folder not found.');
    if (folder.isSystem) throw ArgumentError('System folders cannot be deleted.');

    final allFolders = await _folderRepo.findAll();
    final subfolders = allFolders.where((f) => f.parentId == folderId).toList();
    final allIds = [folderId, ...subfolders.map((f) => f.id)];

    for (final id in allIds) {
      final notes = await _noteRepo.findByFolderId(id);
      if (notes.isEmpty) continue;
      if (action == DeleteFolderAction.moveToStash) {
        await _noteRepo.moveAllToFolder(
            notes.map((n) => n.id).toList(), kStashFolderId);
      } else {
        await _noteRepo.deleteAllInFolder(id);
      }
    }

    for (final subfolder in subfolders) {
      await _folderRepo.delete(subfolder.id);
    }
    await _folderRepo.delete(folderId);
  }
}
