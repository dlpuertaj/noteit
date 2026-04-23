import 'package:notes/models/folder/folder.dart';

abstract class FolderRepository {
  Future<void> insert(Folder folder);
  Future<Folder?> findById(String id);
  Future<List<Folder>> findAll();
  Future<void> update(Folder folder);
  Future<void> delete(String id);
}
