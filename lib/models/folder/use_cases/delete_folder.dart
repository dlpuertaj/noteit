import 'package:notes/models/folder/folder.dart';
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
    final descendants = _collectDescendants(folderId, allFolders);
    final allIds = [folderId, ...descendants.map((f) => f.id)];

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

    descendants.sort((a, b) => b.depth.compareTo(a.depth));
    for (final descendant in descendants) {
      await _folderRepo.delete(descendant.id);
    }
    await _folderRepo.delete(folderId);
  }

  List<Folder> _collectDescendants(String rootId, List<Folder> all) {
    final result = <Folder>[];
    final queue = <String>[rootId];
    while (queue.isNotEmpty) {
      final parentId = queue.removeAt(0);
      for (final f in all) {
        if (f.parentId == parentId) {
          result.add(f);
          queue.add(f.id);
        }
      }
    }
    return result;
  }
}
