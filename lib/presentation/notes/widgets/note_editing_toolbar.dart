import 'package:flutter/material.dart';

class NoteEditingToolbar extends StatelessWidget {
  const NoteEditingToolbar({
    super.key,
    required this.activeUndoNotifier,
    required this.onUndo,
    required this.onRedo,
  });

  final ValueNotifier<UndoHistoryController> activeUndoNotifier;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UndoHistoryController>(
      valueListenable: activeUndoNotifier,
      builder: (context, activeController, _) {
        return ValueListenableBuilder<UndoHistoryValue>(
          valueListenable: activeController,
          builder: (context, value, _) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: value.canUndo ? onUndo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo',
                  onPressed: value.canRedo ? onRedo : null,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
