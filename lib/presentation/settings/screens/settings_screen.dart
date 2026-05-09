import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

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
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text('Maximum folder depth')),
                IconButton(
                  tooltip: 'Decrease max depth',
                  icon: const Icon(Icons.remove),
                  onPressed: settings.maxFolderDepth > 1
                      ? () => ref
                          .read(settingsProvider.notifier)
                          .setMaxFolderDepth(settings.maxFolderDepth - 1)
                      : null,
                ),
                Text('${settings.maxFolderDepth}'),
                IconButton(
                  tooltip: 'Increase max depth',
                  icon: const Icon(Icons.add),
                  onPressed: settings.maxFolderDepth < 5
                      ? () => ref
                          .read(settingsProvider.notifier)
                          .setMaxFolderDepth(settings.maxFolderDepth + 1)
                      : null,
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('Body font size')),
                IconButton(
                  tooltip: 'Decrease font size',
                  icon: const Icon(Icons.remove),
                  onPressed: settings.bodyFontSize > 10
                      ? () => ref
                          .read(settingsProvider.notifier)
                          .setBodyFontSize(settings.bodyFontSize - 2)
                      : null,
                ),
                Text('${settings.bodyFontSize}'),
                IconButton(
                  tooltip: 'Increase font size',
                  icon: const Icon(Icons.add),
                  onPressed: settings.bodyFontSize < 32
                      ? () => ref
                          .read(settingsProvider.notifier)
                          .setBodyFontSize(settings.bodyFontSize + 2)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
