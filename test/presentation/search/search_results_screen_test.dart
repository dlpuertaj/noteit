import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/models/folder/folder.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/presentation/folders/providers/folder_provider.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/presentation/search/providers/search_provider.dart';
import 'package:notes/presentation/search/screens/search_results_screen.dart';
import 'package:notes/utils/constants.dart';

Note _note({String id = 'note-1', String title = 'Flutter Tips'}) {
  final now = DateTime(2024);
  return Note(
      id: id,
      title: title,
      body: '',
      folderId: kInboxFolderId,
      createdAt: now,
      updatedAt: now);
}

Folder _inbox() => Folder(
      id: kInboxFolderId,
      name: 'Inbox',
      parentId: null,
      depth: 1,
      isSystem: true,
      createdAt: DateTime(2024),
    );

class FakeSearchNotifier extends SearchNotifier {
  FakeSearchNotifier(this._resultsMap);
  final Map<String, List<Note>> _resultsMap;

  String? lastQuery;

  @override
  SearchState build() => const SearchState();

  @override
  Future<void> setQuery(String query) async {
    lastQuery = query;
    state = SearchState(query: query, results: _resultsMap[query] ?? []);
  }
}

class FakeNoteNotifier extends NoteNotifier {
  String? loadedNoteId;

  @override
  NoteState build() => const NoteState();

  @override
  Future<void> loadNote(String id) async => loadedNoteId = id;

  @override
  void scheduleAutoSave(String noteId, String title, String body) {}

  @override
  Future<void> deleteCurrentNote() async {}

  @override
  Future<void> createNote({String? folderId}) async {}

  @override
  Future<void> moveNoteToFolder(String noteId, String targetFolderId) async {}

  @override
  Future<void> deleteNoteById(String noteId) async {}
}

class FakeFolderNotifier extends FolderNotifier {
  FakeFolderNotifier(this._folders);
  final List<Folder> _folders;

  @override
  FolderState build() => FolderState(folders: _folders);

  @override
  Future<void> selectFolder(String id) async {}

  @override
  Future<void> createFolder(String name, String? parentId) async {}

  @override
  Future<void> deleteFolder(String id, action) async {}

  @override
  Future<void> renameFolder(String id, String newName) async {}
}

Widget _buildApp({
  Map<String, List<Note>> resultsMap = const {},
  FakeNoteNotifier? noteNotifier,
  List<Folder>? folders,
  GoRouter? router,
}) {
  final fakeSearch = FakeSearchNotifier(resultsMap);
  final fakeNote = noteNotifier ?? FakeNoteNotifier();
  final fakeFolders = folders ?? [_inbox()];

  final appRouter = router ??
      GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(
              path: '/search',
              builder: (_, _) => const SearchResultsScreen()),
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('Note Editor'))),
          ),
        ],
      );

  return ProviderScope(
    overrides: [
      searchProvider.overrideWith(() => fakeSearch),
      noteProvider.overrideWith(() => fakeNote),
      folderProvider.overrideWith(() => FakeFolderNotifier(fakeFolders)),
    ],
    child: MaterialApp.router(routerConfig: appRouter),
  );
}

void main() {
  testWidgets('search field is present and auto-focused on open',
      (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();

    expect(find.byKey(const Key('search_field')), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(const Key('search_field'))).autofocus,
      isTrue,
    );
  });

  testWidgets('results update as user types', (tester) async {
    final note = _note();
    await tester.pumpWidget(_buildApp(resultsMap: {'flutter': [note]}));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('search_field')), 'flutter');
    await tester.pump();

    expect(find.text('Flutter Tips'), findsOneWidget);
  });

  testWidgets('each result shows note title and folder name', (tester) async {
    final note = _note();
    await tester.pumpWidget(_buildApp(
      resultsMap: {'flutter': [note]},
      folders: [_inbox()],
    ));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('search_field')), 'flutter');
    await tester.pump();

    expect(find.text('Flutter Tips'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
  });

  testWidgets('tapping a result loads the note and navigates to /',
      (tester) async {
    final note = _note();
    final noteNotifier = FakeNoteNotifier();
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
            path: '/search',
            builder: (_, _) => const SearchResultsScreen()),
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Note Editor'))),
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(
      resultsMap: {'flutter': [note]},
      noteNotifier: noteNotifier,
      router: router,
    ));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('search_field')), 'flutter');
    await tester.pump();

    await tester.tap(find.text('Flutter Tips'));
    await tester.pumpAndSettle();

    expect(noteNotifier.loadedNoteId, 'note-1');
    expect(find.text('Note Editor'), findsOneWidget);
  });

  testWidgets('empty query shows blank results area with no No notes found',
      (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();

    expect(find.text('No notes found.'), findsNothing);
  });

  testWidgets('non-empty query with no matches shows No notes found',
      (tester) async {
    await tester.pumpWidget(_buildApp(resultsMap: {}));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('search_field')), 'xyz');
    await tester.pump();

    expect(find.text('No notes found.'), findsOneWidget);
  });

  testWidgets('back button navigates to Note Editor', (tester) async {
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
            path: '/search',
            builder: (_, _) => const SearchResultsScreen()),
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Note Editor'))),
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(router: router));
    await tester.pump();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Note Editor'), findsOneWidget);
  });
}
