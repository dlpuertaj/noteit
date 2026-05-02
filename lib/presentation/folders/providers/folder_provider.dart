import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/data/app_database.dart';
import 'package:notes/data/folders/sqflite_folder_repository.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/folder_repository.dart';
import 'package:notes/models/folder/use_cases/create_folder.dart';
import 'package:notes/models/folder/use_cases/delete_folder.dart';
import 'package:notes/models/folder/use_cases/get_folders.dart';
import 'package:notes/models/folder/use_cases/rename_folder.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';
import 'package:notes/utils/constants.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return SqfliteFolderRepository(ref.read(appDatabaseProvider));
});

final _getFoldersProvider = Provider<GetFolders>((ref) {
  return GetFolders(ref.read(folderRepositoryProvider));
});

final _createFolderProvider = Provider<CreateFolder>((ref) {
  return CreateFolder(ref.read(folderRepositoryProvider));
});

final _deleteFolderProvider = Provider<DeleteFolder>((ref) {
  return DeleteFolder(
    ref.read(folderRepositoryProvider),
    ref.read(noteRepositoryProvider),
  );
});

final _renameFolderProvider = Provider<RenameFolder>((ref) {
  return RenameFolder(ref.read(folderRepositoryProvider));
});

class FolderState {
  const FolderState({
    this.folders = const [],
    this.selectedFolderId,
    this.expandedFolderIds = const {},
    this.maxFolderDepth = kDefaultMaxFolderDepth,
  });

  final List<Folder> folders;
  final String? selectedFolderId;
  final Set<String> expandedFolderIds;
  final int maxFolderDepth;

  FolderState copyWith({
    List<Folder>? folders,
    String? selectedFolderId,
    Set<String>? expandedFolderIds,
    int? maxFolderDepth,
  }) =>
      FolderState(
        folders: folders ?? this.folders,
        selectedFolderId: selectedFolderId ?? this.selectedFolderId,
        expandedFolderIds: expandedFolderIds ?? this.expandedFolderIds,
        maxFolderDepth: maxFolderDepth ?? this.maxFolderDepth,
      );
}

class FolderNotifier extends Notifier<FolderState> {
  @override
  FolderState build() {
    ref.listen<int>(settingsProvider, (_, maxDepth) {
      state = state.copyWith(maxFolderDepth: maxDepth);
    });
    Future.microtask(_init);
    return const FolderState();
  }

  Future<void> _init() async {
    final folders = await ref.read(_getFoldersProvider).execute();
    final maxDepth = ref.read(settingsProvider);
    state = FolderState(folders: folders, maxFolderDepth: maxDepth);
  }

  Future<void> selectFolder(String id) async {
    final expanded = Set<String>.from(state.expandedFolderIds);
    expanded.contains(id) ? expanded.remove(id) : expanded.add(id);
    state = FolderState(
      folders: state.folders,
      selectedFolderId: id,
      expandedFolderIds: expanded,
      maxFolderDepth: state.maxFolderDepth,
    );
  }

  Future<void> createFolder(String name, String? parentId) async {
    await ref.read(_createFolderProvider).execute(
          name,
          parentId: parentId,
          maxFolderDepth: state.maxFolderDepth,
        );
    final folders = await ref.read(_getFoldersProvider).execute();
    state = state.copyWith(folders: folders);
  }

  Future<void> deleteFolder(String id, DeleteFolderAction action) async {
    await ref.read(_deleteFolderProvider).execute(id, action);
    final folders = await ref.read(_getFoldersProvider).execute();
    final stillSelected = folders.any((f) => f.id == state.selectedFolderId);
    state = FolderState(
      folders: folders,
      selectedFolderId: stillSelected ? state.selectedFolderId : null,
      expandedFolderIds:
          Set.from(state.expandedFolderIds)..remove(id),
      maxFolderDepth: state.maxFolderDepth,
    );
  }

  Future<void> renameFolder(String id, String newName) async {
    await ref.read(_renameFolderProvider).execute(id, newName);
    final folders = await ref.read(_getFoldersProvider).execute();
    state = state.copyWith(folders: folders);
  }
}

final folderProvider =
    NotifierProvider<FolderNotifier, FolderState>(FolderNotifier.new);
