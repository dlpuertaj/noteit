import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/folder/use_cases/delete_folder.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/presentation/folders/providers/folder_provider.dart';
import 'package:notes/presentation/folders/screens/side_panel_screen.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/utils/constants.dart';

Folder _inbox() => Folder(
      id: kInboxFolderId,
      name: 'Inbox',
      parentId: null,
      depth: 1,
      isSystem: true,
      createdAt: DateTime(2024),
    );

Folder _stash() => Folder(
      id: kStashFolderId,
      name: 'Stash',
      parentId: null,
      depth: 1,
      isSystem: true,
      createdAt: DateTime(2024),
    );

Folder _userFolder({String id = 'folder-1', String name = 'My Folder'}) =>
    Folder(
      id: id,
      name: name,
      parentId: null,
      depth: 1,
      isSystem: false,
      createdAt: DateTime(2024),
    );

Note _note({
  String id = 'note-1',
  String title = 'My Note',
  String folderId = kInboxFolderId,
}) {
  final now = DateTime(2024);
  return Note(
    id: id,
    title: title,
    body: '',
    folderId: folderId,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeFolderNotifier extends FolderNotifier {
  FakeFolderNotifier(this._initial);
  final FolderState _initial;

  String? createdFolderName;
  String? createdFolderParentId;
  String? deletedFolderId;
  DeleteFolderAction? deletedFolderAction;
  String? renamedFolderId;
  String? renamedFolderNewName;

  @override
  FolderState build() => _initial;

  @override
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

  @override
  Future<void> createFolder(String name, String? parentId) async {
    createdFolderName = name;
    createdFolderParentId = parentId;
  }

  @override
  Future<void> deleteFolder(String id, DeleteFolderAction action) async {
    deletedFolderId = id;
    deletedFolderAction = action;
  }

  @override
  Future<void> renameFolder(String id, String newName) async {
    renamedFolderId = id;
    renamedFolderNewName = newName;
  }
}

class FakeNoteNotifier extends NoteNotifier {
  FakeNoteNotifier(this._initial);
  final NoteState _initial;

  String? loadedNoteId;
  String? createdNoteFolderId;
  bool createNoteCalledWithNoFolder = false;
  String? movedNoteId;
  String? moveTargetFolderId;

  @override
  NoteState build() => _initial;

  @override
  Future<void> loadNote(String id) async {
    loadedNoteId = id;
  }

  @override
  Future<void> createNote({String? folderId}) async {
    if (folderId == null) {
      createNoteCalledWithNoFolder = true;
    } else {
      createdNoteFolderId = folderId;
    }
  }

  @override
  Future<void> moveNoteToFolder(String noteId, String targetFolderId) async {
    movedNoteId = noteId;
    moveTargetFolderId = targetFolderId;
  }

  @override
  void scheduleAutoSave(String noteId, String title, String body) {}

  @override
  Future<void> deleteCurrentNote() async {}

  @override
  Future<void> refreshNotes() async {}
}

Widget _buildApp({
  required FolderState folderState,
  required NoteState noteState,
  VoidCallback? onClose,
  FakeFolderNotifier? folderNotifier,
  FakeNoteNotifier? noteNotifier,
}) {
  return ProviderScope(
    overrides: [
      folderProvider.overrideWith(
          () => folderNotifier ?? FakeFolderNotifier(folderState)),
      noteProvider
          .overrideWith(() => noteNotifier ?? FakeNoteNotifier(noteState)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SidePanelScreen(onClose: onClose ?? () {}),
      ),
    ),
  );
}

void main() {
  final inbox = _inbox();
  final stash = _stash();
  final userFolder = _userFolder();
  final inboxNote = _note();

  final baseFolderState = FolderState(
    folders: [inbox, stash, userFolder],
    maxFolderDepth: 2,
  );
  final baseNoteState = NoteState(
    allNotes: [inboxNote],
    currentNote: inboxNote,
  );

  testWidgets('Inbox and Stash appear at the bottom', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: baseNoteState,
    ));

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Stash'), findsOneWidget);

    final inboxDy = tester.getTopLeft(find.text('Inbox')).dy;
    final myFolderDy = tester.getTopLeft(find.text('My Folder')).dy;
    expect(inboxDy, greaterThan(myFolderDy));
  });

  testWidgets('user folders appear above system folders', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: baseNoteState,
    ));

    expect(find.text('My Folder'), findsOneWidget);
    final stashDy = tester.getTopLeft(find.text('Stash')).dy;
    final myFolderDy = tester.getTopLeft(find.text('My Folder')).dy;
    expect(stashDy, greaterThan(myFolderDy));
  });

  testWidgets('tapping a folder reveals its notes', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: baseNoteState,
    ));

    expect(find.text('My Note'), findsNothing);
    await tester.tap(find.text('Inbox'));
    await tester.pump();

    expect(find.text('My Note'), findsOneWidget);
  });

  testWidgets('tapping a note opens it in the editor and closes the panel',
      (tester) async {
    bool closed = false;
    final noteNotifier = FakeNoteNotifier(baseNoteState);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        folderProvider.overrideWith(() => FakeFolderNotifier(FolderState(
          folders: [inbox, stash, userFolder],
          selectedFolderId: kInboxFolderId,
          expandedFolderIds: {kInboxFolderId},
          maxFolderDepth: 2,
        ))),
        noteProvider.overrideWith(() => noteNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SidePanelScreen(onClose: () => closed = true),
        ),
      ),
    ));

    await tester.tap(find.text('My Note'));
    await tester.pump();

    expect(noteNotifier.loadedNoteId, 'note-1');
    expect(closed, isTrue);
  });

  testWidgets(
      'New Note button creates a note in selected folder (Inbox when none selected)',
      (tester) async {
    final noteNotifier = FakeNoteNotifier(baseNoteState);
    bool closed = false;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        folderProvider.overrideWith(() => FakeFolderNotifier(baseFolderState)),
        noteProvider.overrideWith(() => noteNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SidePanelScreen(onClose: () => closed = true),
        ),
      ),
    ));

    await tester.tap(find.text('New Note'));
    await tester.pump();

    expect(noteNotifier.createNoteCalledWithNoFolder, isTrue);
    expect(closed, isTrue);
  });

  testWidgets('New Folder button creates a root folder when none selected',
      (tester) async {
    final folderNotifier = FakeFolderNotifier(baseFolderState);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        folderProvider.overrideWith(() => folderNotifier),
        noteProvider
            .overrideWith(() => FakeNoteNotifier(baseNoteState)),
      ],
      child: MaterialApp(
        home: Scaffold(body: SidePanelScreen(onClose: () {})),
      ),
    ));

    await tester.tap(find.text('New Folder'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Work');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(folderNotifier.createdFolderName, 'Work');
    expect(folderNotifier.createdFolderParentId, isNull);
  });

  testWidgets('tap-hold on a user folder shows Delete', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: baseNoteState,
    ));

    await tester.longPress(find.text('My Folder'));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('tap-hold on a system folder does NOT show Delete', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: baseNoteState,
    ));

    await tester.longPress(find.text('Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsNothing);
  });

  testWidgets(
      'Delete on a folder with notes shows count prompt with Move to Stash and Delete permanently',
      (tester) async {
    final noteInFolder =
        _note(id: 'note-2', folderId: 'folder-1', title: 'Work Note');

    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: NoteState(
        allNotes: [inboxNote, noteInFolder],
        currentNote: inboxNote,
      ),
    ));

    await tester.longPress(find.text('My Folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 note'), findsOneWidget);
    expect(find.text('Move to Stash'), findsOneWidget);
    expect(find.text('Delete permanently'), findsOneWidget);
  });

  testWidgets('tap-hold on a note shows Delete and Move to...', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: FolderState(
        folders: [inbox, stash, userFolder],
        selectedFolderId: kInboxFolderId,
        expandedFolderIds: {kInboxFolderId},
        maxFolderDepth: 2,
      ),
      noteState: baseNoteState,
    ));

    await tester.longPress(find.text('My Note'));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Move to...'), findsOneWidget);
  });

  testWidgets('tap-hold on a user folder shows Rename and Delete', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: baseFolderState,
      noteState: baseNoteState,
    ));

    await tester.longPress(find.text('My Folder'));
    await tester.pumpAndSettle();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Rename on a folder calls renameFolder on provider', (tester) async {
    final folderNotifier = FakeFolderNotifier(baseFolderState);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        folderProvider.overrideWith(() => folderNotifier),
        noteProvider.overrideWith(() => FakeNoteNotifier(baseNoteState)),
      ],
      child: MaterialApp(
        home: Scaffold(body: SidePanelScreen(onClose: () {})),
      ),
    ));

    await tester.longPress(find.text('My Folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Work');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(folderNotifier.renamedFolderId, 'folder-1');
    expect(folderNotifier.renamedFolderNewName, 'Work');
  });

  testWidgets('Move to... opens the folder picker', (tester) async {
    await tester.pumpWidget(_buildApp(
      folderState: FolderState(
        folders: [inbox, stash, userFolder],
        selectedFolderId: kInboxFolderId,
        expandedFolderIds: {kInboxFolderId},
        maxFolderDepth: 2,
      ),
      noteState: baseNoteState,
    ));

    await tester.longPress(find.text('My Note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to...'));
    await tester.pumpAndSettle();

    expect(find.text('Move to folder'), findsOneWidget);
  });
}
