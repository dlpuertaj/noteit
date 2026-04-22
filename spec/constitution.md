# Constitution — Notes App

**Version:** 1.0  
**Date:** 2026-04-20  
**Status:** Signed off

---

## 1. Purpose

A minimal, distraction-free notes app for Android. The app exists to let anyone write, organize, and find notes quickly — with no setup, no account, and no internet required.

---

## 2. Target Users

Anyone who needs to capture notes on any subject. No assumed technical skill level. No assumed use case.

---

## 3. Core Principles

- **Simplicity over features.** Four features only: write, organize, search, export.
- **The writing surface is the app.** The note editor occupies the full screen.
- **No friction at startup.** No login, no onboarding, no permissions dialogs beyond storage.
- **Auto-save.** Notes are saved automatically as the user types. No manual save action required.
- **Calm UI.** No loud colors, no cluttered toolbars, no decorative chrome.

---

## 4. Non-Negotiable Constraints

| Constraint | Detail |
|---|---|
| Platform | Android (primary). Flutter codebase allows other platforms later. |
| Offline-only | No network calls. No sync. No cloud. Ever. |
| Local storage | All data stored on-device using a local database. |
| No authentication | No user registration, no login, no accounts. |
| No external services | No analytics, no crash reporting, no ads. |
| Max folder depth | Configurable by the user in Settings. Default is 2 levels (Root → Folder → Subfolder). The UI must prevent creating folders beyond the configured limit. |

---

## 5. MVP Feature Scope

The app is considered MVP-complete when a user can:

1. **Write notes** — Create, edit, and delete a note. The editor is full-screen.
2. **Organize notes in folders** — Create, rename, and delete folders. Folders can be nested up to **2 levels deep** (Root → Folder → Subfolder). Notes can be moved into any folder. Two system folders exist at root level and cannot be deleted or renamed: **Inbox** (notes created without a folder selection) and **Stash** (notes rescued from deleted folders or deleted permanently at the user's choice).
3. **Search notes by title** — A search finds notes whose title matches the query. Search is not required to scan note body content.
4. **Export a note** — The user can share, print, or download the current note.

Everything outside this list is explicitly **post-MVP**.

---

## 6. Post-MVP (Out of Scope for Now)

- Note body search
- Tags or labels
- Markdown rendering
- Themes or color customization
- Pinning or starring notes
- Sort order preferences
- Undo/redo history

---

## 7. Success Criteria

The MVP is complete when:

- A user can open the app cold and immediately start writing a note.
- That note survives the app being closed and reopened.
- The user can create a folder hierarchy (at least 2 levels deep) and place notes inside.
- Deleting a note removes it permanently.
- Deleting a folder that contains notes (including in nested subfolders) prompts the user: "This folder contains X notes. What do you want to do with them?" with two options: **Move to Stash** or **Delete permanently**. If the folder is empty, it is removed immediately without a prompt.
- Searching by title returns the correct notes.
- The user can share, print, or download a note from the export screen.
- The app functions entirely without an internet connection.

---

## 8. Tech Stack

| Concern | Choice |
|---|---|
| Language | Dart |
| Framework | Flutter |
| State management | Riverpod |
| Local storage | sqflite (SQLite) |
| Navigation | Go Router |

---

## 9. Agent 3-Tier Boundary

Rules that govern how the AI agent (Claude) must behave throughout this project.

### Always Do
- Apply clean code principles at all times (meaningful names, single responsibility, DRY, small functions).
- Always verify dependency versions against pub.dev before adding or updating them in the plan. Never assume a version — always look it up.

### Ask First
- Before running any shell command or script.
- Before editing the database schema or data.
- Before executing any git command (commit, push, pull, merge, rebase, etc.).

### Never Do
- Never store passwords, API keys, tokens, or any sensitive credentials in code.
- Never commit sensitive information to version control.
- Never begin implementation of any phase until all tasks for **all phases** are fully written in `tasks.md` and approved by the user.
- Never blur the boundary between the Tasks phase and the Implementation phase — writing tasks and executing tasks are two separate steps.

---

## 10. What This Constitution Does Not Decide

The Constitution defines **what** and **why**. It does not decide:

- Exact UI layout details (decided in Specification)
- Export format details, e.g. PDF vs plain text (decided in Specification)
