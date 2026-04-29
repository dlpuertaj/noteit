import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/folders/screens/side_panel_screen.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';
import 'package:notes/presentation/notes/widgets/note_body_field.dart';
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
  bool _isSidePanelOpen = false;
  String? _loadedNoteId;

  @override
  void initState() {
    super.initState();
    _syncFromState(ref.read(noteProvider));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
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
                  onPressed: () => setState(() => _isSidePanelOpen = true),
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
                onPressed: () => context.go('/export'),
              ),
              NoteThreeDotMenu(onDeleteNote: _confirmDelete),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                NoteTitleField(
                  controller: _titleController,
                  onChanged: _scheduleAutoSave,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: NoteBodyField(
                    controller: _bodyController,
                    onChanged: _scheduleAutoSave,
                  ),
                ),
              ],
            ),
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
