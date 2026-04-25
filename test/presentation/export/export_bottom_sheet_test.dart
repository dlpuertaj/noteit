import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/presentation/export/export_service.dart';
import 'package:notes/presentation/export/screens/export_bottom_sheet.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/utils/constants.dart';

class FakeExportService implements ExportService {
  bool shareCalled = false;
  bool printCalled = false;
  bool downloadCalled = false;
  bool downloadSucceeds = true;
  String? lastShareTitle;
  String? lastShareText;

  @override
  Future<void> share(String title, String text) async {
    shareCalled = true;
    lastShareTitle = title;
    lastShareText = text;
  }

  @override
  Future<void> printNote(String title, String text) async {
    printCalled = true;
  }

  @override
  Future<bool> download(String title, String text) async {
    downloadCalled = true;
    return downloadSucceeds;
  }
}

class FakeNoteNotifier extends NoteNotifier {
  FakeNoteNotifier(this._state);
  final NoteState _state;

  @override
  NoteState build() => _state;

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

Note _note({String title = 'My Title', String body = 'My body text'}) {
  final now = DateTime(2024);
  return Note(
    id: 'note-1',
    title: title,
    body: body,
    folderId: kInboxFolderId,
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _showSheet(
  WidgetTester tester, {
  required FakeExportService service,
  Note? note,
}) async {
  final noteState = NoteState(currentNote: note ?? _note());

  await tester.pumpWidget(ProviderScope(
    overrides: [
      exportServiceProvider.overrideWithValue(service),
      noteProvider.overrideWith(() => FakeNoteNotifier(noteState)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const ExportBottomSheet(),
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('Show'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Share, Print, and Download buttons are all visible',
      (tester) async {
    await _showSheet(tester, service: FakeExportService());

    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
  });

  testWidgets('tapping Share calls service with note content as plain text',
      (tester) async {
    final service = FakeExportService();
    await _showSheet(tester, service: service,
        note: _note(title: 'My Title', body: 'My body text'));

    await tester.tap(find.text('Share'));
    await tester.pump();

    expect(service.shareCalled, isTrue);
    expect(service.lastShareTitle, 'My Title');
    expect(service.lastShareText, 'My body text');
  });

  testWidgets('tapping Print calls service', (tester) async {
    final service = FakeExportService();
    await _showSheet(tester, service: service);

    await tester.tap(find.text('Print'));
    await tester.pump();

    expect(service.printCalled, isTrue);
  });

  testWidgets('tapping Download calls service', (tester) async {
    final service = FakeExportService();
    await _showSheet(tester, service: service);

    await tester.tap(find.text('Download'));
    await tester.pump();

    expect(service.downloadCalled, isTrue);
  });

  testWidgets(
      'storage permission failure on Download shows error message',
      (tester) async {
    final service = FakeExportService()..downloadSucceeds = false;
    await _showSheet(tester, service: service);

    await tester.tap(find.text('Download'));
    await tester.pump();

    expect(
      find.text(
          'Could not save file. Please check storage permissions.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping outside the sheet dismisses it', (tester) async {
    await _showSheet(tester, service: FakeExportService());

    expect(find.text('Share'), findsOneWidget);

    // tap the scrim above the sheet
    await tester.tapAt(const Offset(200, 100));
    await tester.pumpAndSettle();

    expect(find.text('Share'), findsNothing);
  });
}
