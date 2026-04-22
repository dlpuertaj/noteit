# Tasks — Notes App

**Governed by:** plan.md, spec.md, constitution.md  
**Method:** TDD — write the test first (red), then the code (green), then refactor.

---

## Status Legend

- [x] Not started
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
- [x] **T-009** Run `flutter pub get` to install all dependencies

### 1.2 Create folder structure

- [x] **T-013** Create `lib/data/notes/`
- [x] **T-014** Create `lib/data/folders/`
- [x] **T-015** Create `lib/domain/notes/use_cases/`
- [x] **T-016** Create `lib/domain/folders/use_cases/`
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

**Domain layer — notes:**
- [x] **T-034** Create empty `lib/domain/notes/note.dart`
- [x] **T-035** Create empty `lib/domain/notes/note_repository.dart`
- [x] **T-036** Create empty `lib/domain/notes/use_cases/create_note.dart`
- [x] **T-037** Create empty `lib/domain/notes/use_cases/edit_note.dart`
- [x] **T-038** Create empty `lib/domain/notes/use_cases/delete_note.dart`
- [x] **T-039** Create empty `lib/domain/notes/use_cases/get_note.dart`
- [x] **T-040** Create empty `lib/domain/notes/use_cases/get_all_notes.dart`
- [x] **T-041** Create empty `lib/domain/notes/use_cases/search_notes_by_title.dart`

**Domain layer — folders:**
- [x] **T-042** Create empty `lib/domain/folders/folder.dart`
- [x] **T-043** Create empty `lib/domain/folders/folder_repository.dart`
- [x] **T-044** Create empty `lib/domain/folders/use_cases/create_folder.dart`
- [x] **T-045** Create empty `lib/domain/folders/use_cases/rename_folder.dart`
- [x] **T-046** Create empty `lib/domain/folders/use_cases/delete_folder.dart`
- [x] **T-047** Create empty `lib/domain/folders/use_cases/get_folders.dart`
- [x] **T-048** Create empty `lib/domain/folders/use_cases/get_notes_in_folder.dart`
- [x] **T-049** Create empty `lib/domain/folders/use_cases/move_note_to_folder.dart`

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

*Tasks to be written after Phase 1 is complete.*

---

## Phase 3 — Domain Layer

*Tasks to be written after Phase 2 is complete.*

---

## Phase 4 — Presentation Layer

*Tasks to be written after Phase 3 is complete.*

---

## Phase 5 — Utils

*Tasks to be written after Phase 4 is complete.*
