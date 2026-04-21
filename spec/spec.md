# Specification — Notes App

**Version:** 1.0  
**Date:** 2026-04-21  
**Status:** Draft  
**Governed by:** constitution.md

---

## 1. Data Models

### 1.1 Note

| Field | Type | Description |
|---|---|---|
| `id` | String (UUID) | Unique identifier, generated on creation |
| `title` | String | The note's title. Must not be empty. Max 200 characters. |
| `body` | String | The note's content. May be empty. |
| `folderId` | String (UUID) | The ID of the folder this note belongs to. Always set — defaults to the Inbox system folder if no folder is selected. |
| `createdAt` | DateTime | Timestamp of creation. Set once on creation, never modified. |
| `updatedAt` | DateTime | Timestamp of last edit. Updated on every auto-save. |

**Rules:**
- A note must always belong to exactly one folder.
- A note with no explicit folder selection must be assigned to Inbox.
- A note's title defaults to "Untitled" if the user leaves the title field empty when navigating away.

---

### 1.2 Folder

| Field | Type | Description |
|---|---|---|
| `id` | String (UUID) | Unique identifier, generated on creation |
| `name` | String | Display name. Must not be empty. Max 100 characters. |
| `parentId` | String (UUID) \| null | ID of the parent folder. Null means the folder is at root level. |
| `depth` | Integer | 1 = root-level folder, 2 = subfolder. Enforced by the app. |
| `isSystem` | Boolean | True for Inbox and Stash. System folders cannot be renamed or deleted. |
| `createdAt` | DateTime | Timestamp of creation. |

**Rules:**
- A folder at depth 1 must have `parentId` = null.
- A folder at depth 2 must have `parentId` pointing to a depth-1 folder.
- Creating a folder inside a depth-2 folder is forbidden. The UI must not offer this option.
- The maximum allowed depth is configurable in Settings (default: 2). The app must enforce the configured limit.
- The names "Inbox" and "Stash" are reserved for system folders and must not be usable for user-created folders.

---

### 1.3 System Folders

Two system folders are created automatically on first app launch and always exist at root level:

| Name | Purpose |
|---|---|
| **Inbox** | Receives notes created without an explicit folder selection. |
| **Stash** | Receives notes moved out of deleted folders (when user chooses "Move to Stash"). |

**Rules:**
- System folders must not be deletable.
- System folders must not be renameable.
- System folders must not accept child folders (no subfolders inside Inbox or Stash).
- System folders are always visible at the top of the root folder list.

---

### 1.4 Settings

| Field | Type | Description |
|---|---|---|
| `maxFolderDepth` | Integer | Maximum allowed nesting depth for user folders. Default: 2. Min: 1. Max: 5. |

---

## 2. Screen Inventory

| Screen | Purpose |
|---|---|
| **Note Editor** | Full-screen writing surface. The primary screen of the app. |
| **Side Panel** | Slide-in panel showing the folder tree and notes list. |
| **Search Results** | Replaces the Note Editor while searching. |
| **Export Screen** | Bottom sheet with export actions: Share, Print, Download. |
| **Settings Screen** | Displays and edits app settings. |

---

## 3. Screen Behavior

### 3.1 Note Editor

- Occupies the full screen.
- Contains two fields: **Title** (single line, top) and **Body** (multiline, fills remaining space).
- The app auto-saves after every change. No manual save action exists.
- On first launch (no notes exist), the editor opens empty and ready to write.
- On subsequent launches, the editor reopens the last active note.
- If no notes exist, a new empty note is created automatically on launch.

**Action buttons on this screen:**
| Button | Action |
|---|---|
| Side Panel button | Opens the Side Panel |
| Search button | Replaces this screen with the Search Results screen |
| Export button | Opens the Export Screen |
| Settings button | Navigates to the Settings Screen |
| Three-dot menu | Shows options: **Delete note** |

**Three-dot menu — Delete note:**
- Tapping "Delete note" shows a confirmation dialog: "Delete this note? This cannot be undone."
- Confirming deletes the note permanently.
- After deletion, the app opens the next available note, or creates a new empty note if none exist.

---

### 3.2 Side Panel

- Slides in from the left over the Note Editor.
- Tapping outside the panel closes it.
- Displays the full folder tree: system folders (Inbox, Stash) at the top, then user folders below.
- Folders at depth 1 can be expanded to show their subfolders.
- Tapping a folder shows the notes inside it within the panel.
- Tapping a note in the panel opens it in the Note Editor and closes the panel.

**Action buttons on this screen:**
| Button | Condition | Action |
|---|---|---|
| New Note button | Always visible | Creates a new note in the currently selected folder. If no folder is selected, note goes to Inbox. |
| New Folder button | Always visible | Creates a new folder. If a folder is selected, the new folder is created inside it (if depth allows). If no folder is selected or the selected folder is at max depth, the new folder is created at root. |

**Tap-hold (1 second) on a folder or note:**
- Shows a context menu with: **Delete**
- Tapping Delete on a **note** shows: "Delete this note? This cannot be undone." Confirming deletes permanently.
- Tapping Delete on a **folder:**
  - If the folder is empty: deletes immediately, no prompt.
  - If the folder contains notes (at any nesting level): shows prompt — "This folder contains X notes. What do you want to do with them?" with two options:
    - **Move to Stash** — moves all notes to the Stash folder, then deletes the folder.
    - **Delete permanently** — deletes all notes and the folder permanently.
- System folders (Inbox, Stash) must not show a Delete option on tap-hold.

---

### 3.3 Search Results Screen

- Replaces the Note Editor when the user taps the Search button.
- Displays a search input field, focused and ready to type immediately.
- Results update in real time as the user types.
- Search matches note **titles** only (case-insensitive, partial match allowed).
- Each result shows the note title and the folder it belongs to.
- Tapping a result opens that note in the Note Editor and dismisses the Search Results screen.
- If no results match, displays: "No notes found."
- Tapping the back button or pressing the device back gesture returns to the Note Editor.

---

### 3.4 Export Screen

- Opens as a bottom sheet over the Note Editor.
- Displays three actions:

| Action | Behavior |
|---|---|
| **Share** | Opens the Android system share sheet with the note content as plain text. |
| **Print** | Opens the Android print dialog with the note formatted for printing. |
| **Download** | Saves the note as a `.txt` file to the device's Downloads folder. |

- The note is exported as plain text in all cases.
- Tapping outside the bottom sheet or the close button dismisses it.

---

### 3.5 Settings Screen

- Navigated to from the Note Editor.
- Contains one setting:

| Setting | Type | Default | Constraint |
|---|---|---|---|
| Maximum folder depth | Integer selector | 2 | Min: 1, Max: 5 |

- Changing the max folder depth takes effect immediately.
- If the new max depth is lower than the current folder structure, existing folders that exceed the new limit are **not** automatically deleted — the limit only prevents new folders from being created beyond it.
- A back button returns to the Note Editor.

---

## 4. Navigation Flow

```
Note Editor
  ├── [Side Panel button]   → Side Panel (overlay)
  │     └── [tap note]      → Note Editor (same screen, new note loaded)
  ├── [Search button]       → Search Results (replaces Note Editor)
  │     └── [tap result]    → Note Editor (same screen, selected note loaded)
  │     └── [back]          → Note Editor
  ├── [Export button]       → Export Screen (bottom sheet)
  │     └── [dismiss]       → Note Editor
  └── [Settings button]     → Settings Screen
        └── [back]          → Note Editor
```

---

## 5. Edge Cases

| Scenario | Expected Behavior |
|---|---|
| User launches app for the first time | System folders (Inbox, Stash) are created. A new empty note is opened. |
| User creates a note without selecting a folder | Note is saved to Inbox. |
| User tries to create a folder inside a system folder | The New Folder button must not offer this option when Inbox or Stash is selected. |
| User tries to create a folder at max depth | The New Folder button must not be offered for folders at the configured max depth. |
| User searches with an empty query | No results are shown. The "No notes found." message is not shown either — the results area is blank. |
| User deletes the note currently open in the editor | The next available note is loaded. If none exist, a new empty note is created. |
| User renames a folder to "Inbox" or "Stash" | The app must reject the name and show an error: "This name is reserved." |
| Download fails (e.g. storage permission denied) | The app shows an error message: "Could not save file. Please check storage permissions." |
| Note title is left empty | Title defaults to "Untitled" on auto-save. |
