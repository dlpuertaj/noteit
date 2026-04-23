import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';

class GetFolders {
  GetFolders(this._repo);

  final FolderRepository _repo;

  Future<List<Folder>> execute() => _repo.findAll();
}
