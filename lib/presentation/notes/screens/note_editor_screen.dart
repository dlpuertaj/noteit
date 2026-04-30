import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/folders/screens/side_panel_screen.dart';
import 'package:notes/presentation/folders/widgets/folder_picker.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/presentation/notes/widgets/note_body_field.dart';
import 'package:notes/presentation/notes/widgets/note_editing_toolbar.dart';
import 'package:notes/presentation/notes/widgets/note_three_dot_menu.dart';
import 'package:notes/presentation/notes/widgets/note_title_field.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _bodyFocusNode = FocusNode();
  final _titleUndoController = UndoHistoryController();
  final _bodyUndoController = UndoHistoryController();
  late final ValueNotifier<UndoHistoryController> _activeUndoNotifier;
  bool _isSidePanelOpen = false;
  String? _loadedNoteId;

  @override
  void initState() {
    super.initState();
    _activeUndoNotifier = ValueNotifier(_bodyUndoController);
    _titleFocusNode.addListener(_onTitleFocus);
    _bodyFocusNode.addListener(_onBodyFocus);
    _syncFromState(ref.read(noteProvider));
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_onTitleFocus);
    _bodyFocusNode.removeListener(_onBodyFocus);
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    _titleUndoController.dispose();
    _bodyUndoController.dispose();
    _activeUndoNotifier.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onTitleFocus() {
    if (_titleFocusNode.hasFocus) _activeUndoNotifier.value = _titleUndoController;
  }

  void _onBodyFocus() {
    if (_bodyFocusNode.hasFocus) _activeUndoNotifier.value = _bodyUndoController;
  }

  void _syncFromState(NoteState noteState) {
    final note = noteState.currentNote;
    if (note == null || note.id == _loadedNoteId) return;
    _loadedNoteId = note.id;
    _titleController.text = note.title;
    _bodyController.text = note.body;
  }

  void _scheduleAutoSave() {
    final note = ref.read(noteProvider).currentNote;
    if (note == null) return;
    ref.read(noteProvider.notifier).scheduleAutoSave(
          note.id,
          _titleController.text,
          _bodyController.text,
        );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('Delete this note? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(noteProvider.notifier).deleteCurrentNote();
    }
  }

  void _moveCurrentNote() {
    final noteId = ref.read(noteProvider).currentNote?.id;
    if (noteId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FolderPicker(noteId: noteId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NoteState>(noteProvider, (_, next) => _syncFromState(next));

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 96,
            leading: Row(
              children: [
                IconButton(
                  tooltip: 'Open side panel',
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _isSidePanelOpen = true);
                  },
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.go('/settings'),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () => context.go('/search'),
              ),
              IconButton(
                tooltip: 'Export',
                icon: const Icon(Icons.ios_share),
                onPressed: () => context.push('/export'),
              ),
              NoteThreeDotMenu(
                onDeleteNote: _confirmDelete,
                onMoveNote: _moveCurrentNote,
              ),
            ],
          ),
          body: Column(
            children: [
              NoteEditingToolbar(
                activeUndoNotifier: _activeUndoNotifier,
                onUndo: () => _activeUndoNotifier.value.undo(),
                onRedo: () => _activeUndoNotifier.value.redo(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      NoteTitleField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        undoController: _titleUndoController,
                        onChanged: _scheduleAutoSave,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: NoteBodyField(
                          controller: _bodyController,
                          focusNode: _bodyFocusNode,
                          undoController: _bodyUndoController,
                          onChanged: _scheduleAutoSave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isSidePanelOpen) ...[
          GestureDetector(
            onTap: () => setState(() => _isSidePanelOpen = false),
            child: Container(color: Colors.black54),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SidePanelScreen(
              key: const Key('side_panel'),
              onClose: () => setState(() => _isSidePanelOpen = false),
            ),
          ),
        ],
      ],
    );
  }
}
