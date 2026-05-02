import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/data/app_database.dart';
import 'package:notes/data/notes/sqflite_note_repository.dart';
import 'package:notes/models/folder/use_cases/move_note_to_folder.dart';
import 'package:notes/models/note/note.dart';
import 'package:notes/models/note/note_repository.dart';
import 'package:notes/models/note/use_cases/create_note.dart';
import 'package:notes/models/note/use_cases/delete_note.dart';
import 'package:notes/models/note/use_cases/edit_note.dart';
import 'package:notes/models/note/use_cases/get_all_notes.dart';
import 'package:notes/models/note/use_cases/get_note.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return SqfliteNoteRepository(ref.read(appDatabaseProvider));
});

final _createNoteProvider = Provider<CreateNote>((ref) {
  return CreateNote(ref.read(noteRepositoryProvider));
});

final _editNoteProvider = Provider<EditNote>((ref) {
  return EditNote(ref.read(noteRepositoryProvider));
});

final _deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.read(noteRepositoryProvider));
});

final _getAllNotesProvider = Provider<GetAllNotes>((ref) {
  return GetAllNotes(ref.read(noteRepositoryProvider));
});

final _getNoteProvider = Provider<GetNote>((ref) {
  return GetNote(ref.read(noteRepositoryProvider));
});

final _moveNoteToFolderProvider = Provider<MoveNoteToFolder>((ref) {
  return MoveNoteToFolder(ref.read(noteRepositoryProvider));
});

class NoteState {
  const NoteState({
    this.currentNote,
    this.allNotes = const [],
    this.isLoading = false,
  });

  final Note? currentNote;
  final List<Note> allNotes;
  final bool isLoading;

  NoteState copyWith({
    Note? currentNote,
    List<Note>? allNotes,
    bool? isLoading,
  }) =>
      NoteState(
        currentNote: currentNote ?? this.currentNote,
        allNotes: allNotes ?? this.allNotes,
        isLoading: isLoading ?? this.isLoading,
      );
}

class NoteNotifier extends Notifier<NoteState> {
  Timer? _debounceTimer;

  @override
  NoteState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    Future.microtask(_init);
    return const NoteState(isLoading: true);
  }

  Future<void> _init() async {
    final notes = await ref.read(_getAllNotesProvider).execute();
    if (notes.isEmpty) {
      final note = await ref.read(_createNoteProvider).execute('', '');
      state = NoteState(currentNote: note, allNotes: [note]);
    } else {
      state = NoteState(currentNote: notes.last, allNotes: notes);
    }
  }

  void scheduleAutoSave(String noteId, String title, String body) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await ref.read(_editNoteProvider).execute(noteId, title, body);
      final notes = await ref.read(_getAllNotesProvider).execute();
      final updated = notes.firstWhere(
        (n) => n.id == noteId,
        orElse: () => state.currentNote!,
      );
      state = NoteState(currentNote: updated, allNotes: notes);
    });
  }

  Future<void> loadNote(String id) async {
    final note = await ref.read(_getNoteProvider).execute(id);
    if (note != null) state = state.copyWith(currentNote: note);
  }

  Future<void> createNote({String? folderId}) async {
    final note = await ref
        .read(_createNoteProvider)
        .execute('', '', folderId: folderId);
    state = NoteState(
      currentNote: note,
      allNotes: [...state.allNotes, note],
    );
  }

  Future<void> deleteCurrentNote() async {
    final current = state.currentNote;
    if (current == null) return;
    _debounceTimer?.cancel();
    await ref.read(_deleteNoteProvider).execute(current.id);
    final remaining = state.allNotes.where((n) => n.id != current.id).toList();
    if (remaining.isEmpty) {
      final newNote = await ref.read(_createNoteProvider).execute('', '');
      state = NoteState(currentNote: newNote, allNotes: [newNote]);
    } else {
      state = NoteState(currentNote: remaining.last, allNotes: remaining);
    }
  }

  Future<void> refreshNotes() async {
    final notes = await ref.read(_getAllNotesProvider).execute();
    final current = state.currentNote;
    final updated = current == null
        ? null
        : notes.firstWhere((n) => n.id == current.id, orElse: () => current);
    state = NoteState(currentNote: updated, allNotes: notes);
  }

  Future<void> deleteNoteById(String noteId) async {
    if (state.currentNote?.id == noteId) _debounceTimer?.cancel();
    await ref.read(_deleteNoteProvider).execute(noteId);
    final remaining = state.allNotes.where((n) => n.id != noteId).toList();
    if (state.currentNote?.id == noteId) {
      if (remaining.isEmpty) {
        final newNote = await ref.read(_createNoteProvider).execute('', '');
        state = NoteState(currentNote: newNote, allNotes: [newNote]);
      } else {
        state = NoteState(currentNote: remaining.last, allNotes: remaining);
      }
    } else {
      state = state.copyWith(allNotes: remaining);
    }
  }

  Future<void> moveNoteToFolder(String noteId, String targetFolderId) async {
    await ref.read(_moveNoteToFolderProvider).execute(noteId, targetFolderId);
    final notes = await ref.read(_getAllNotesProvider).execute();
    final updatedCurrent = notes.firstWhere(
      (n) => n.id == state.currentNote?.id,
      orElse: () => state.currentNote!,
    );
    state = NoteState(currentNote: updatedCurrent, allNotes: notes);
  }
}

final noteProvider = NotifierProvider<NoteNotifier, NoteState>(NoteNotifier.new);
