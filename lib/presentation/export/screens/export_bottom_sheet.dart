import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/presentation/export/export_service.dart';
import 'package:notes/presentation/notes/providers/note_provider.dart';

class ExportBottomSheet extends ConsumerWidget {
  const ExportBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteProvider).currentNote;
    final service = ref.read(exportServiceProvider);
    final title = note?.title ?? '';
    final body = note?.body ?? '';

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () async {
              await service.share(title, body);
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print'),
            onTap: () async {
              await service.printNote(title, body);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download'),
            onTap: () async {
              final success = await service.download(title, body);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not save file. Please check storage permissions.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
