# Plan — Notes App

**Version:** 1.0  
**Date:** 2026-04-21  
**Status:** Draft  
**Governed by:** constitution.md, spec.md

---

## 1. Dependencies

| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.4.2 | Local SQLite database |
| `flutter_riverpod` | ^3.3.1 | State management with Flutter bindings |
| `go_router` | ^17.2.2 | Navigation |
| `path_provider` | ^2.1.5 | Locating device storage paths (required by Isar) |
| `share_plus` | ^13.1.0 | Android share sheet for export |
| `printing` | ^5.14.3 | Print dialog for export |
| `uuid` | ^4.5.3 | Generating unique IDs for notes and folders |

**Dev dependencies:**

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | SDK | Widget and unit testing (included by default) |
| `mocktail` | ^1.0.5 | Mocking repository interfaces in unit tests |

---

## 2. Folder Structure

```
lib/
  data/
    app_database.dart
    notes/
      note_repository.dart
      sqflite_note_repository.dart
    folders/
      folder_repository.dart
      sqflite_folder_repository.dart
  domain/
    notes/
      note.dart
      note_repository.dart
      use_cases/
        create_note.dart
        edit_note.dart
        delete_note.dart
        get_note.dart
        get_all_notes.dart
        search_notes_by_title.dart
    folders/
      folder.dart
      folder_repository.dart
      use_cases/
        create_folder.dart
        rename_folder.dart
        delete_folder.dart
        get_folders.dart
        get_notes_in_folder.dart
        move_note_to_folder.dart
  presentation/
    notes/
      screens/
        note_editor_screen.dart
      widgets/
        note_title_field.dart
        note_body_field.dart
        note_three_dot_menu.dart
      providers/
        note_provider.dart
    folders/
      screens/
        side_panel_screen.dart
      widgets/
        folder_tree.dart
        folder_item.dart
        note_item.dart
        folder_picker.dart
      providers/
        folder_provider.dart
    search/
      screens/
        search_results_screen.dart
      widgets/
        search_bar.dart
        search_result_item.dart
      providers/
        search_provider.dart
    export/
      screens/
        export_bottom_sheet.dart
    settings/
      screens/
        settings_screen.dart
      providers/
        settings_provider.dart
  utils/
    router.dart
    constants.dart
    extensions.dart
```

---

## 3. Layer Responsibilities

| Layer | Responsibility | Knows About |
|---|---|---|
| **Data** | Isar schemas, repository implementations | Isar only |
| **Domain** | Entities, use cases, repository interfaces | Pure Dart only |
| **Presentation** | Screens, widgets, Riverpod providers | Flutter, Domain |
| **Utils** | Routing, constants, shared extensions | All layers |

**Key rules:**
- The domain layer must never import Flutter or Isar.
- The data layer must never import Flutter widgets.
- Every repository must have an abstract interface (domain) and a concrete Isar implementation (data). This satisfies the Dependency Inversion principle.
- Providers call use cases. Use cases call repository interfaces. Repositories talk to Isar.

---

## 4. Data Layer

### Database
A single `AppDatabase` class initializes sqflite, creates the tables on first launch, and is injected into repositories.

| Table | Columns |
|---|---|
| `notes` | id, title, body, folder_id, created_at, updated_at |
| `folders` | id, name, parent_id, depth, is_system, created_at |

### Repositories
Each repository has two files:
- **Interface** in `domain/` — defines the contract (abstract class)
- **Implementation** in `data/` — implements the contract using sqflite

---

## 5. Domain Layer

### Entities
Pure Dart classes with no framework dependencies. Mirror the schemas but without Isar annotations.

| Entity | Fields |
|---|---|
| `Note` | id, title, body, folderId, createdAt, updatedAt |
| `Folder` | id, name, parentId, depth, isSystem, createdAt |

### Use Cases
One class per user action. Each use case receives its dependencies via constructor injection and exposes a single `execute()` method.

**Notes:**
- `CreateNote` — creates a note in the given folder (defaults to Inbox)
- `EditNote` — updates title and/or body, triggers auto-save
- `DeleteNote` — permanently deletes a note
- `GetNote` — fetches a single note by id
- `GetAllNotes` — fetches all notes
- `SearchNotesByTitle` — returns notes whose title matches a query (case-insensitive, partial match)

**Folders:**
- `CreateFolder` — creates a folder, enforces max depth from settings
- `RenameFolder` — renames a folder, rejects reserved names (Inbox, Stash)
- `DeleteFolder` — deletes a folder, handles note migration (Stash or permanent delete)
- `GetFolders` — fetches the full folder tree
- `GetNotesInFolder` — fetches all notes in a given folder
- `MoveNoteToFolder` — moves a note to any folder including system folders

---

## 6. Presentation Layer

### Providers
Riverpod providers sit between the UI and the domain layer. They hold state and call use cases when the user takes an action.

| Provider | State | Calls |
|---|---|---|
| `note_provider` | Current note, all notes | Note use cases |
| `folder_provider` | Folder tree, selected folder | Folder use cases |
| `search_provider` | Search query, search results | `SearchNotesByTitle` |
| `settings_provider` | `maxFolderDepth` | Reads/writes settings |

### Screens and Widgets

| Screen | Key Widgets |
|---|---|
| `NoteEditorScreen` | `NoteTitleField`, `NoteBodyField`, `NoteThreeDotMenu` |
| `SidePanelScreen` | `FolderTree`, `FolderItem`, `NoteItem`, `FolderPicker` |
| `SearchResultsScreen` | `SearchBar`, `SearchResultItem` |
| `ExportBottomSheet` | Inline — no sub-widgets needed |
| `SettingsScreen` | Inline — no sub-widgets needed |

---

## 7. Navigation

All routes are defined in `utils/router.dart` using Go Router.

| Route | Screen | Type |
|---|---|---|
| `/` | `NoteEditorScreen` | Full page — root |
| `/settings` | `SettingsScreen` | Full page |
| `/search` | `SearchResultsScreen` | Full page |
| `/export` | `ExportBottomSheet` | Modal overlay |
| `/folders/picker` | `FolderPicker` | Modal overlay |

The Side Panel is a widget overlay within `NoteEditorScreen`, not a route.

---

## 8. Implementation Order (TDD)

For every feature: **write the test first (red) → write the code (green) → refactor.**

```
1. Project setup
   - Add dependencies: isar, isar_flutter_libs, riverpod,
     flutter_riverpod, go_router, path_provider, share_plus,
     printing, flutter_test
   - Create full folder structure
   - Router skeleton (empty routes)

2. Data layer — for each entity (Note, then Folder):
   2.1 Write integration test for repository (red)
   2.2 Write Isar schema
   2.3 Write repository interface (in domain/)
   2.4 Write Isar implementation (in data/)
   2.5 Pass the test (green)
   2.6 Refactor if needed

3. Domain layer — for each use case (Notes first, then Folders):
   3.1 Write unit test for use case (red)
   3.2 Write entity
   3.3 Write use case
   3.4 Pass the test (green)
   3.5 Refactor if needed

4. Presentation layer — one feature at a time:
   4.1 Note Editor
   4.2 Side Panel
   4.3 Search
   4.4 Export
   4.5 Settings

   For each feature:
   4.x.1 Write widget test (red)
   4.x.2 Write provider
   4.x.3 Write screen and widgets
   4.x.4 Pass the test (green)
   4.x.5 Refactor if needed

5. Utils
   - Wire up Go Router with all routes
   - Define constants (reserved names, default max depth, etc.)
   - Add extensions if needed
```
