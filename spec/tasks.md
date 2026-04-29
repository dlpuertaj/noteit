# Tasks — Notes App

**Governed by:** plan.md, spec.md, constitution.md  
**Method:** TDD — write the test first (red), then the code (green), then refactor.

---

## Status Legend

- [ ] Not started
- [~] In progress
- [x] Done

---

## Phase 1 — Project Setup

### 1.1 Add dependencies

- [x] **T-001** Add `sqflite` to dependencies in `pubspec.yaml`
- [x] **T-002** Add `flutter_riverpod` to dependencies in `pubspec.yaml`
- [x] **T-003** Add `go_router` to dependencies in `pubspec.yaml`
- [x] **T-004** Add `path_provider` to dependencies in `pubspec.yaml`
- [x] **T-005** Add `share_plus` to dependencies in `pubspec.yaml`
- [x] **T-006** Add `printing` to dependencies in `pubspec.yaml`
- [x] **T-007** Add `uuid` to dependencies in `pubspec.yaml`
- [x] **T-008** Add `mocktail` to dev_dependencies in `pubspec.yaml`
- [x] **T-010** Verify latest `sqflite_common_ffi` version on pub.dev and add it to `dev_dependencies` in `pubspec.yaml`. Required to run sqflite tests without a device.
- [x] **T-011** Run `flutter pub get` to install all dependencies

### 1.2 Create folder structure

- [x] **T-013** Create `lib/data/notes/`
- [x] **T-014** Create `lib/data/folders/`
- [x] **T-015** Create `lib/models/note/use_cases/`
- [x] **T-016** Create `lib/models/folder/use_cases/`
- [x] **T-017** Create `lib/presentation/notes/screens/`
- [x] **T-018** Create `lib/presentation/notes/widgets/`
- [x] **T-019** Create `lib/presentation/notes/providers/`
- [x] **T-020** Create `lib/presentation/folders/screens/`
- [x] **T-021** Create `lib/presentation/folders/widgets/`
- [x] **T-022** Create `lib/presentation/folders/providers/`
- [x] **T-023** Create `lib/presentation/search/screens/`
- [x] **T-024** Create `lib/presentation/search/widgets/`
- [x] **T-025** Create `lib/presentation/search/providers/`
- [x] **T-026** Create `lib/presentation/export/screens/`
- [x] **T-027** Create `lib/presentation/settings/screens/`
- [x] **T-028** Create `lib/presentation/settings/providers/`
- [x] **T-029** Create `lib/utils/`

### 1.3 Create placeholder files

**Data layer:**
- [x] **T-030** Create empty `lib/data/app_database.dart`
- [x] **T-031** Create empty `lib/data/notes/sqflite_note_repository.dart`
- [x] **T-032** Create empty `lib/data/folders/sqflite_folder_repository.dart`

**Models layer — notes:**
- [x] **T-034** Create empty `lib/models/note/note.dart`
- [x] **T-035** Create empty `lib/models/note/note_repository.dart`
- [x] **T-036** Create empty `lib/models/note/use_cases/create_note.dart`
- [x] **T-037** Create empty `lib/models/note/use_cases/edit_note.dart`
- [x] **T-038** Create empty `lib/models/note/use_cases/delete_note.dart`
- [x] **T-039** Create empty `lib/models/note/use_cases/get_note.dart`
- [x] **T-040** Create empty `lib/models/note/use_cases/get_all_notes.dart`
- [x] **T-041** Create empty `lib/models/note/use_cases/search_notes_by_title.dart`

**Models layer — folders:**
- [x] **T-042** Create empty `lib/models/folder/folder.dart`
- [x] **T-043** Create empty `lib/models/folder/folder_repository.dart`
- [x] **T-044** Create empty `lib/models/folder/use_cases/create_folder.dart`
- [x] **T-045** Create empty `lib/models/folder/use_cases/rename_folder.dart`
- [x] **T-046** Create empty `lib/models/folder/use_cases/delete_folder.dart`
- [x] **T-047** Create empty `lib/models/folder/use_cases/get_folders.dart`
- [x] **T-048** Create empty `lib/models/folder/use_cases/get_notes_in_folder.dart`
- [x] **T-049** Create empty `lib/models/folder/use_cases/move_note_to_folder.dart`

**Presentation layer:**
- [x] **T-050** Create empty `lib/presentation/notes/screens/note_editor_screen.dart`
- [x] **T-051** Create empty `lib/presentation/notes/widgets/note_title_field.dart`
- [x] **T-052** Create empty `lib/presentation/notes/widgets/note_body_field.dart`
- [x] **T-053** Create empty `lib/presentation/notes/widgets/note_three_dot_menu.dart`
- [x] **T-054** Create empty `lib/presentation/notes/providers/note_provider.dart`
- [x] **T-055** Create empty `lib/presentation/folders/screens/side_panel_screen.dart`
- [x] **T-056** Create empty `lib/presentation/folders/widgets/folder_tree.dart`
- [x] **T-057** Create empty `lib/presentation/folders/widgets/folder_item.dart`
- [x] **T-058** Create empty `lib/presentation/folders/widgets/note_item.dart`
- [x] **T-059** Create empty `lib/presentation/folders/widgets/folder_picker.dart`
- [x] **T-060** Create empty `lib/presentation/folders/providers/folder_provider.dart`
- [x] **T-061** Create empty `lib/presentation/search/screens/search_results_screen.dart`
- [x] **T-062** Create empty `lib/presentation/search/widgets/search_bar.dart`
- [x] **T-063** Create empty `lib/presentation/search/widgets/search_result_item.dart`
- [x] **T-064** Create empty `lib/presentation/search/providers/search_provider.dart`
- [x] **T-065** Create empty `lib/presentation/export/screens/export_bottom_sheet.dart`
- [x] **T-066** Create empty `lib/presentation/settings/screens/settings_screen.dart`
- [x] **T-067** Create empty `lib/presentation/settings/providers/settings_provider.dart`

**Utils:**
- [x] **T-068** Create empty `lib/utils/router.dart`
- [x] **T-069** Create empty `lib/utils/constants.dart`
- [x] **T-070** Create empty `lib/utils/extensions.dart`

### 1.4 Router skeleton

- [x] **T-071** Define all 5 routes in `lib/utils/router.dart` pointing to empty placeholder screens
- [x] **T-072** Wire `router.dart` into `main.dart` so the app compiles and launches

---

## Phase 2 — Data Layer

### 2.1 Entity classes

These are pure Dart classes with no framework dependencies. They must exist before repository interfaces can be defined.

- [x] **T-102** Implement `Note` in `lib/models/note/note.dart` — fields: `id` (String), `title` (String), `body` (String), `folderId` (String), `createdAt` (DateTime), `updatedAt` (DateTime). Immutable; provide `copyWith`.
- [x] **T-103** Implement `Folder` in `lib/models/folder/folder.dart` — fields: `id` (String), `name` (String), `parentId` (String?), `depth` (int), `isSystem` (bool), `createdAt` (DateTime). Immutable; provide `copyWith`.

### 2.2 AppDatabase

- [x] **T-104** Write integration test for `AppDatabase` in `test/data/app_database_test.dart`. Test cases: (a) `notes` table exists with columns `id`, `title`, `body`, `folder_id`, `created_at`, `updated_at`; (b) `folders` table exists with columns `id`, `name`, `parent_id`, `depth`, `is_system`, `created_at`; (c) `settings` table exists with column `max_folder_depth`; (d) Inbox system folder is present after init; (e) Stash system folder is present after init; (f) re-initializing does not duplicate system folders or settings row. Use in-memory database via `sqflite_common_ffi`.
- [x] **T-105** Implement `AppDatabase` in `lib/data/app_database.dart` — `onCreate` creates `notes`, `folders`, and `settings` tables; seeds Inbox and Stash system folders with fixed UUIDs and `is_system = 1`; seeds one `settings` row with `max_folder_depth = 2`. Expose a `database` getter of type `Future<Database>`.
- [x] **T-106** Run `flutter test test/data/app_database_test.dart` — confirm all tests pass (green).

### 2.3 Note Repository

- [x] **T-107** Write integration tests for `SqfliteNoteRepository` in `test/data/notes/sqflite_note_repository_test.dart`. Test cases: insert then findById returns the note; findAll returns all inserted notes; findByFolderId returns only notes in that folder; searchByTitle returns partial case-insensitive matches; searchByTitle returns empty list for empty query; update persists changes to title, body, folderId, and updatedAt; delete makes findById return null; deleteAllInFolder removes all notes with that folderId; moveAllToFolder updates folderId for all given ids. Use in-memory database.
- [x] **T-108** Define `NoteRepository` abstract class in `lib/models/note/note_repository.dart` with async methods: `insert(Note)`, `findById(String)`, `findAll()`, `findByFolderId(String)`, `searchByTitle(String)`, `update(Note)`, `delete(String)`, `deleteAllInFolder(String)`, `moveAllToFolder(List<String> ids, String targetFolderId)`.
- [x] **T-109** Implement `SqfliteNoteRepository` in `lib/data/notes/sqflite_note_repository.dart` — implements `NoteRepository`, takes `AppDatabase` in constructor, maps `Note` ↔ sqflite row maps.
- [x] **T-110** Run `flutter test test/data/notes/` — confirm all tests pass (green).

### 2.4 Folder Repository

- [x] **T-111** Write integration tests for `SqfliteFolderRepository` in `test/data/folders/sqflite_folder_repository_test.dart`. Test cases: insert then findById returns the folder; findAll includes system folders seeded by AppDatabase; update persists name change; delete removes a non-system folder (findById returns null after delete). Use in-memory database.
- [x] **T-112** Define `FolderRepository` abstract class in `lib/models/folder/folder_repository.dart` with async methods: `insert(Folder)`, `findById(String)`, `findAll()`, `update(Folder)`, `delete(String)`.
- [x] **T-113** Implement `SqfliteFolderRepository` in `lib/data/folders/sqflite_folder_repository.dart` — implements `FolderRepository`, takes `AppDatabase` in constructor, maps `Folder` ↔ sqflite row maps.
- [x] **T-114** Run `flutter test test/data/folders/` — confirm all tests pass (green).

---

## Phase 3 — Models Layer (Use Cases)

Use `mocktail` to mock `NoteRepository` and `FolderRepository` in all use-case tests.

### 3.1 CreateNote

- [x] **T-200** Write unit test in `test/models/note/use_cases/create_note_test.dart`. Test cases: created note has a non-empty UUID id; title and body match inputs; folderId matches input; createdAt equals updatedAt; when no folderId is given, folderId defaults to the Inbox system folder ID.
- [x] **T-201** Implement `CreateNote` in `lib/models/note/use_cases/create_note.dart` — constructor takes `NoteRepository`; `execute(title, body, {folderId})` generates UUID, sets createdAt/updatedAt to now, inserts via repository, returns `Note`.
- [x] **T-202** Run `flutter test test/models/note/use_cases/create_note_test.dart` (green).

### 3.2 EditNote

- [x] **T-203** Write unit test in `test/models/note/use_cases/edit_note_test.dart`. Test cases: title is updated; body is updated; updatedAt is set to current time; title that is blank after trim defaults to "Untitled".
- [x] **T-204** Implement `EditNote` in `lib/models/note/use_cases/edit_note.dart` — constructor takes `NoteRepository`; `execute(noteId, title, body)` fetches note, trims title (defaults to "Untitled" if blank), sets updatedAt to now, calls repository.update.
- [x] **T-205** Run `flutter test test/models/note/use_cases/edit_note_test.dart` (green).

### 3.3 DeleteNote

- [x] **T-206** Write unit test in `test/models/note/use_cases/delete_note_test.dart`. Test case: repository.delete is called with the correct id.
- [x] **T-207** Implement `DeleteNote` in `lib/models/note/use_cases/delete_note.dart` — constructor takes `NoteRepository`; `execute(noteId)` calls repository.delete.
- [x] **T-208** Run `flutter test test/models/note/use_cases/delete_note_test.dart` (green).

### 3.4 GetNote

- [x] **T-209** Write unit test in `test/models/note/use_cases/get_note_test.dart`. Test cases: returns note when found; returns null when not found.
- [x] **T-210** Implement `GetNote` in `lib/models/note/use_cases/get_note.dart` — constructor takes `NoteRepository`; `execute(noteId)` returns `repository.findById(noteId)`.
- [x] **T-211** Run `flutter test test/models/note/use_cases/get_note_test.dart` (green).

### 3.5 GetAllNotes

- [x] **T-212** Write unit test in `test/models/note/use_cases/get_all_notes_test.dart`. Test cases: returns empty list when no notes; returns all notes.
- [x] **T-213** Implement `GetAllNotes` in `lib/models/note/use_cases/get_all_notes.dart` — constructor takes `NoteRepository`; `execute()` returns `repository.findAll()`.
- [x] **T-214** Run `flutter test test/models/note/use_cases/get_all_notes_test.dart` (green).

### 3.6 SearchNotesByTitle

- [x] **T-215** Write unit test in `test/models/note/use_cases/search_notes_by_title_test.dart`. Test cases: empty query returns empty list without calling repository; non-empty query delegates to `repository.searchByTitle`.
- [x] **T-216** Implement `SearchNotesByTitle` in `lib/models/note/use_cases/search_notes_by_title.dart` — constructor takes `NoteRepository`; `execute(query)` returns empty list if query is blank, otherwise returns `repository.searchByTitle(query)`.
- [x] **T-217** Run `flutter test test/models/note/use_cases/search_notes_by_title_test.dart` (green).

### 3.7 CreateFolder

- [x] **T-218** Write unit test in `test/models/folder/use_cases/create_folder_test.dart`. Test cases: root folder has depth 1 and parentId null; subfolder has depth 2 and correct parentId; isSystem is false; throws `ArgumentError` when name is "Inbox" (case-insensitive); throws `ArgumentError` when name is "Stash" (case-insensitive); throws `ArgumentError` when resulting depth would exceed maxFolderDepth.
- [x] **T-219** Implement `CreateFolder` in `lib/models/folder/use_cases/create_folder.dart` — constructor takes `FolderRepository`; `execute(name, parentId, maxFolderDepth)` validates name and depth, generates UUID, sets createdAt, inserts via repository, returns `Folder`.
- [x] **T-220** Run `flutter test test/models/folder/use_cases/create_folder_test.dart` (green).

### 3.8 RenameFolder

- [x] **T-221** Write unit test in `test/models/folder/use_cases/rename_folder_test.dart`. Test cases: repository.update is called with new name; throws `ArgumentError` when new name is "Inbox"; throws `ArgumentError` when new name is "Stash"; throws `ArgumentError` when folder has `isSystem = true`.
- [x] **T-222** Implement `RenameFolder` in `lib/models/folder/use_cases/rename_folder.dart` — constructor takes `FolderRepository`; `execute(folderId, newName)` fetches folder, validates, calls repository.update with updated name.
- [x] **T-223** Run `flutter test test/models/folder/use_cases/rename_folder_test.dart` (green).

### 3.9 DeleteFolder

- [x] **T-224** Write unit test in `test/models/folder/use_cases/delete_folder_test.dart`. Test cases: empty folder is deleted immediately with no note operations; when `moveToStash` chosen and folder has notes, all notes are moved to Stash folder ID then folder is deleted; when `deletePermanently` chosen, all notes in folder are deleted then folder is deleted; throws `ArgumentError` when folder is a system folder; notes in subfolders are also handled during deletion.
- [x] **T-225** Implement `DeleteFolder` in `lib/models/folder/use_cases/delete_folder.dart` — constructor takes `FolderRepository` and `NoteRepository`; `execute(folderId, action)` where `action` is `DeleteFolderAction.moveToStash` or `DeleteFolderAction.deletePermanently`; fetches folder, validates not a system folder, resolves subfolders, applies action to all notes, then deletes folder(s).
- [x] **T-226** Run `flutter test test/models/folder/use_cases/delete_folder_test.dart` (green).

### 3.10 GetFolders

- [x] **T-227** Write unit test in `test/models/folder/use_cases/get_folders_test.dart`. Test case: delegates to `repository.findAll()`.
- [x] **T-228** Implement `GetFolders` in `lib/models/folder/use_cases/get_folders.dart` — constructor takes `FolderRepository`; `execute()` returns `repository.findAll()`.
- [x] **T-229** Run `flutter test test/models/folder/use_cases/get_folders_test.dart` (green).

### 3.11 GetNotesInFolder

- [x] **T-230** Write unit test in `test/models/folder/use_cases/get_notes_in_folder_test.dart`. Test case: delegates to `repository.findByFolderId(folderId)`.
- [x] **T-231** Implement `GetNotesInFolder` in `lib/models/folder/use_cases/get_notes_in_folder.dart` — constructor takes `NoteRepository`; `execute(folderId)` returns `repository.findByFolderId(folderId)`.
- [x] **T-232** Run `flutter test test/models/folder/use_cases/get_notes_in_folder_test.dart` (green).

### 3.12 MoveNoteToFolder

- [x] **T-233** Write unit test in `test/models/folder/use_cases/move_note_to_folder_test.dart`. Test case: fetches the note, sets folderId to targetFolderId, calls repository.update.
- [x] **T-234** Implement `MoveNoteToFolder` in `lib/models/folder/use_cases/move_note_to_folder.dart` — constructor takes `NoteRepository`; `execute(noteId, targetFolderId)` fetches note, applies updated folderId, calls repository.update.
- [x] **T-235** Run `flutter test test/models/folder/use_cases/move_note_to_folder_test.dart` (green).

---

## Phase 4 — Presentation Layer

For each feature: write widget test (red) → implement provider → implement screen and widgets → pass the test (green) → refactor.


### 4.1 Note Editor

- [x] **T-304** Write widget test in `test/presentation/notes/note_editor_screen_test.dart`. Test cases: displays current note title and body; typing in title triggers auto-save via `EditNote`; typing in body triggers auto-save; tapping Settings button navigates to `/settings`; tapping Search button navigates to `/search`; tapping Export button navigates to `/export`; tapping Side Panel button shows the side panel overlay; three-dot menu contains "Delete note"; tapping "Delete note" shows confirmation dialog; confirming delete calls `DeleteNote` and loads the next available note.
- [x] **T-305** Implement `NoteNotifier` and `noteProvider` in `lib/presentation/notes/providers/note_provider.dart` — state holds current note and full notes list; auto-save debounces field changes and calls `EditNote`; exposes `loadNote(String id)`, `createNote({String? folderId})`, `deleteCurrentNote()`.
- [x] **T-306** Implement `NoteTitleField` in `lib/presentation/notes/widgets/note_title_field.dart` — single-line text field at the top of the editor; notifies provider on change.
- [x] **T-307** Implement `NoteBodyField` in `lib/presentation/notes/widgets/note_body_field.dart` — multiline text field that fills remaining screen space; notifies provider on change.
- [x] **T-308** Implement `NoteThreeDotMenu` in `lib/presentation/notes/widgets/note_three_dot_menu.dart` — popup menu with "Delete note"; shows confirmation dialog before calling provider.
- [x] **T-309** Implement `NoteEditorScreen` in `lib/presentation/notes/screens/note_editor_screen.dart` — full-screen layout with AppBar (Side Panel, Search, Export, Settings buttons + three-dot menu) and body containing `NoteTitleField` and `NoteBodyField`; Side Panel rendered as an overlay, not a route.
- [x] **T-310** Run `flutter test test/presentation/notes/` (green).

### 4.2 Side Panel

- [x] **T-311** Write widget test in `test/presentation/folders/side_panel_screen_test.dart`. Test cases: Inbox and Stash appear at the top; user folders appear below; tapping a folder reveals its notes; tapping a note opens it in the editor and closes the panel; "New Note" button creates a note in the selected folder (or Inbox if none selected); "New Folder" button creates a folder at the correct depth; tap-hold on a user folder shows Delete; tap-hold on a system folder does NOT show Delete; Delete on a folder with notes shows count prompt with "Move to Stash" and "Delete permanently" options; tap-hold on a note shows "Delete" and "Move to..."; "Move to..." opens the folder picker.
- [x] **T-312** Implement `FolderNotifier` and `folderProvider` in `lib/presentation/folders/providers/folder_provider.dart` — state holds full folder tree and selected folder id; exposes `selectFolder(String id)`, `createFolder(String name, String? parentId)`, `deleteFolder(String id, DeleteFolderAction action)`, `renameFolder(String id, String newName)`.
- [x] **T-313** Implement `FolderItem` in `lib/presentation/folders/widgets/folder_item.dart` — shows folder name; expandable to show subfolders; tap-hold context menu (Delete for user folders; no Delete for system folders).
- [x] **T-314** Implement `NoteItem` in `lib/presentation/folders/widgets/note_item.dart` — shows note title; tap opens note; tap-hold context menu ("Delete", "Move to...").
- [x] **T-315** Implement `FolderTree` in `lib/presentation/folders/widgets/folder_tree.dart` — renders system folders (Inbox, Stash) first, then user folders, using `FolderItem` and `NoteItem`.
- [x] **T-316** Implement `FolderPicker` in `lib/presentation/folders/widgets/folder_picker.dart` — full-screen modal showing all folders including Inbox and Stash; tapping a folder calls `MoveNoteToFolder` and dismisses.
- [x] **T-317** Implement `SidePanelScreen` in `lib/presentation/folders/screens/side_panel_screen.dart` — slides in from the left as an overlay; contains `FolderTree` plus "New Note" and "New Folder" buttons; tapping outside closes it.
- [x] **T-318** Run `flutter test test/presentation/folders/` (green).

### 4.3 Settings

- [x] **T-300** Write widget test in `test/presentation/settings/settings_screen_test.dart`. Test cases: screen shows current `maxFolderDepth` value; increasing the value saves the new value; decreasing the value saves the new value; value is clamped to range 1–5; back button navigates back to Note Editor.
- [x] **T-301** Implement `SettingsNotifier` and `settingsProvider` in `lib/presentation/settings/providers/settings_provider.dart` — reads `max_folder_depth` from the `settings` table via `AppDatabase` on init; exposes `maxFolderDepth` as state; provides `setMaxFolderDepth(int value)` that persists the new value to the database.
- [x] **T-302** Implement `SettingsScreen` in `lib/presentation/settings/screens/settings_screen.dart` — shows a numeric selector for `maxFolderDepth` (min 1, max 5); changes take effect immediately; back button returns to Note Editor.
- [x] **T-303** Run `flutter test test/presentation/settings/` (green).


### 4.4 Search

- [x] **T-319** Write widget test in `test/presentation/search/search_results_screen_test.dart`. Test cases: search field is auto-focused on open; results update as user types; each result shows note title and folder name; tapping a result opens the note in the editor and dismisses search; empty query shows blank results area (no "No notes found."); no match shows "No notes found."; back button returns to Note Editor.
- [x] **T-320** Implement `SearchNotifier` and `searchProvider` in `lib/presentation/search/providers/search_provider.dart` — state holds query string and list of matching notes; `setQuery(String)` calls `SearchNotesByTitle`.
- [x] **T-321** Implement `SearchBar` widget in `lib/presentation/search/widgets/search_bar.dart` — auto-focused text field; notifies provider on every change.
- [x] **T-322** Implement `SearchResultItem` in `lib/presentation/search/widgets/search_result_item.dart` — displays note title and the name of its folder.
- [x] **T-323** Implement `SearchResultsScreen` in `lib/presentation/search/screens/search_results_screen.dart` — full-screen layout with `SearchBar` at top and scrollable list of `SearchResultItem` widgets below.
- [x] **T-324** Run `flutter test test/presentation/search/` (green).

### 4.5 Export

- [x] **T-325** Write widget test in `test/presentation/export/export_bottom_sheet_test.dart`. Test cases: Share, Print, and Download buttons are all visible; tapping Share calls `share_plus` with note content as plain text; tapping Print calls the `printing` package; tapping Download saves a `.txt` file to the Downloads folder; storage permission failure on Download shows error "Could not save file. Please check storage permissions."; tapping outside the sheet dismisses it.
- [x] **T-326** Implement `ExportBottomSheet` in `lib/presentation/export/screens/export_bottom_sheet.dart` — bottom sheet with Share, Print, and Download action buttons using the current note's title and body as plain text.
- [x] **T-327** Run `flutter test test/presentation/export/` (green).

---

## Phase 5 — Utils

- [x] **T-400** Define constants in `lib/utils/constants.dart` — Inbox system folder UUID (fixed), Stash system folder UUID (fixed), reserved folder names list (`["Inbox", "Stash"]`), default max folder depth (2).
- [x] **T-401** Update `lib/utils/router.dart` — replace all placeholder screens with the real screen widgets from the presentation layer.
- [x] **T-402** Verify Side Panel is wired as an overlay inside `NoteEditorScreen` (not a separate route), per the navigation spec.
- [x] **T-403** Run `flutter analyze` — zero errors and zero warnings.
- [x] **T-404** Run `flutter test` — all tests pass.

---

## Phase 6 — Bug Fixes & Enhancements

### 6.1 Move to... in Note Editor three-dot menu

- [ ] **T-500** Add `onMoveNote` callback to `NoteThreeDotMenu` widget. Add "Move to..." as a second menu item. Existing "Delete note" behavior unchanged.
- [ ] **T-501** Wire `onMoveNote` in `NoteEditorScreen` — reads `currentNote.id` from `noteProvider`, pushes the `/folders/picker` route passing the note id.
- [ ] **T-502** Update widget test in `test/presentation/notes/note_editor_screen_test.dart` — add test: three-dot menu contains "Move to..."; tapping it opens the folder picker.

### 6.2 Undo and Redo

- [ ] **T-503** Create `NoteEditingToolbar` widget in `lib/presentation/notes/widgets/note_editing_toolbar.dart` — a `Row` with Undo and Redo `IconButton`s. Accepts two `UndoHistoryController`s (title, body) and disables the respective button when history is empty.
- [ ] **T-504** Add `UndoHistoryController` to `NoteTitleField` and `NoteBodyField` — pass controllers up to `NoteEditorScreen` so `NoteEditingToolbar` can observe them.
- [ ] **T-505** Integrate `NoteEditingToolbar` into `NoteEditorScreen` — place it between the AppBar and `NoteTitleField`.
- [ ] **T-506** Write widget test for `NoteEditingToolbar` — test cases: Undo button is disabled when history is empty; Undo button is enabled after text is typed; tapping Undo reverts the last change; same for Redo.

### 6.3 Bug — Subfolder creation

- [ ] **T-507** Investigate and fix: tapping a depth-1 user folder then pressing "New Folder" should create a subfolder inside it. Trace through `FolderNotifier.selectFolder` → `_showNewFolderDialog` → `CreateFolder.execute` and find where the parentId is lost or the depth check fails.
- [ ] **T-508** Add or update widget test in `test/presentation/folders/side_panel_screen_test.dart` to cover subfolder creation: select a user folder, tap "New Folder", confirm → `createdFolderParentId` equals the selected folder's id.

### 6.4 Folder selection highlight

- [ ] **T-509** Add `isSelected` parameter to `FolderItem`. Apply a full-row highlight color (e.g. `Theme.of(context).colorScheme.primaryContainer`) to the `ListTile` when `isSelected` is true.
- [ ] **T-510** Pass `selectedFolderId` from `FolderTree` down to each `FolderItem` so it can compute `isSelected`.
- [ ] **T-511** Update `FolderTree` constructor to accept `selectedFolderId` and thread it to `FolderItem`.
- [ ] **T-512** Update `SidePanelScreen` to pass `folderState.selectedFolderId` to `FolderTree`.
- [ ] **T-513** Update widget test to cover: tapping a folder highlights that folder's row; other folders are not highlighted.

### 6.5 Bug — Keyboard stays open when side panel is opened

- [ ] **T-514** In `NoteEditorScreen`, call `FocusManager.instance.primaryFocus?.unfocus()` when the Side Panel button is tapped (before setting `_isSidePanelOpen = true`).
- [ ] **T-515** In `SidePanelScreen`, wrap `onFolderTap` and `onNoteSelected` callbacks to also call `FocusManager.instance.primaryFocus?.unfocus()` before executing the original callback.

### 6.6 Folder hierarchy lines

- [ ] **T-516** In `FolderItem`, when `folder.depth > 1`, draw a vertical line on the left side of the tile using a `Container` with a left border or a `CustomPaint` decoration to indicate it is a child of a parent folder.
- [ ] **T-517** Adjust the indent in `FolderTree` so subfolder items are indented relative to their parent and the hierarchy line aligns correctly.

### 6.7 Bug — Delete note from side panel creates Untitled when no notes remain

- [ ] **T-518** Verify `NoteNotifier.deleteNoteById` correctly handles the zero-remaining-notes case: ensure the newly created empty note is the current note and allNotes is updated atomically. Add a unit/widget test for this path if not already covered.

### 6.8 Regression check

- [ ] **T-519** Run `flutter analyze` — zero errors and zero warnings.
- [ ] **T-520** Run `flutter test` — all tests pass.
