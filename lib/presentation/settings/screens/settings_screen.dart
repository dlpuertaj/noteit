import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depth = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(child: Text('Maximum folder depth')),
            IconButton(
              tooltip: 'Decrease',
              icon: const Icon(Icons.remove),
              onPressed: depth > 1
                  ? () => ref
                      .read(settingsProvider.notifier)
                      .setMaxFolderDepth(depth - 1)
                  : null,
            ),
            Text('$depth'),
            IconButton(
              tooltip: 'Increase',
              icon: const Icon(Icons.add),
              onPressed: depth < 5
                  ? () => ref
                      .read(settingsProvider.notifier)
                      .setMaxFolderDepth(depth + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
