import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/presentation/notes/screens/note_editor_screen.dart';

Note _testNote({String title = 'My Note', String body = 'Hello world'}) {
  final now = DateTime(2024, 1, 1, 12, 0);
  return Note(
    id: 'note-1',
    title: title,
    body: body,
    folderId: 'inbox',
    createdAt: now,
    updatedAt: now,
  );
}

class FakeNoteNotifier extends NoteNotifier {
  FakeNoteNotifier(this._initial);
  final NoteState _initial;

  bool autoSaveCalled = false;
  bool deleteCalled = false;
  String? lastAutoSaveTitle;
  String? lastAutoSaveBody;

  @override
  NoteState build() => _initial;

  @override
  void scheduleAutoSave(String noteId, String title, String body) {
    autoSaveCalled = true;
    lastAutoSaveTitle = title;
    lastAutoSaveBody = body;
  }

  @override
  Future<void> deleteCurrentNote() async {
    deleteCalled = true;
    state = const NoteState();
  }
}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const NoteEditorScreen()),
        GoRoute(
          path: '/settings',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Settings Screen'))),
        ),
        GoRoute(
          path: '/search',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Search Screen'))),
        ),
        GoRoute(
          path: '/export',
          pageBuilder: (_, _) => const MaterialPage(
            fullscreenDialog: true,
            child: Scaffold(body: Center(child: Text('Export Screen'))),
          ),
        ),
      ],
    );

Widget _buildApp(NoteState state, {GoRouter? router}) {
  return ProviderScope(
    overrides: [
      noteProvider.overrideWith(() => FakeNoteNotifier(state)),
    ],
    child: MaterialApp.router(routerConfig: router ?? _testRouter()),
  );
}

void main() {
  final note = _testNote();
  final noteState = NoteState(currentNote: note, allNotes: [note]);

  testWidgets('displays current note title and body', (tester) async {
    await tester.pumpWidget(_buildApp(noteState));
    await tester.pump();

    expect(find.text('My Note'), findsOneWidget);
    expect(find.text('Hello world'), findsOneWidget);
  });

  testWidgets('typing in title schedules auto-save', (tester) async {
    final notifier = FakeNoteNotifier(noteState);
    await tester.pumpWidget(ProviderScope(
      overrides: [noteProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(routerConfig: _testRouter()),
    ));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('note_title_field')), 'New Title');
    await tester.pump();

    expect(notifier.autoSaveCalled, isTrue);
    expect(notifier.lastAutoSaveTitle, 'New Title');
  });

  testWidgets('typing in body schedules auto-save', (tester) async {
    final notifier = FakeNoteNotifier(noteState);
    await tester.pumpWidget(ProviderScope(
      overrides: [noteProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(routerConfig: _testRouter()),
    ));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('note_body_field')), 'New body');
    await tester.pump();

    expect(notifier.autoSaveCalled, isTrue);
    expect(notifier.lastAutoSaveBody, 'New body');
  });

  testWidgets('tapping Settings button navigates to /settings', (tester) async {
    final router = _testRouter();
    await tester.pumpWidget(_buildApp(noteState, router: router));
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings Screen'), findsOneWidget);
  });

  testWidgets('tapping Search button navigates to /search', (tester) async {
    final router = _testRouter();
    await tester.pumpWidget(_buildApp(noteState, router: router));
    await tester.pump();

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Search Screen'), findsOneWidget);
  });

  testWidgets('tapping Export button navigates to /export', (tester) async {
    final router = _testRouter();
    await tester.pumpWidget(_buildApp(noteState, router: router));
    await tester.pump();

    await tester.tap(find.byTooltip('Export'));
    await tester.pumpAndSettle();

    expect(find.text('Export Screen'), findsOneWidget);
  });

  testWidgets('tapping Side Panel button shows the side panel overlay',
      (tester) async {
    await tester.pumpWidget(_buildApp(noteState));
    await tester.pump();

    await tester.tap(find.byTooltip('Open side panel'));
    await tester.pump();

    expect(find.byKey(const Key('side_panel')), findsOneWidget);
  });

  testWidgets('three-dot menu contains Delete note', (tester) async {
    await tester.pumpWidget(_buildApp(noteState));
    await tester.pump();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Delete note'), findsOneWidget);
  });

  testWidgets('tapping Delete note shows confirmation dialog', (tester) async {
    await tester.pumpWidget(_buildApp(noteState));
    await tester.pump();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete note'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this note? This cannot be undone.'), findsOneWidget);
  });

  testWidgets('confirming delete calls deleteCurrentNote on provider',
      (tester) async {
    final notifier = FakeNoteNotifier(noteState);
    await tester.pumpWidget(ProviderScope(
      overrides: [noteProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(routerConfig: _testRouter()),
    ));
    await tester.pump();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(notifier.deleteCalled, isTrue);
  });
}
