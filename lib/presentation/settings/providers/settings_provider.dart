import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/data/app_database.dart';
import 'package:notes/utils/constants.dart';

class SettingsNotifier extends Notifier<int> {
  @override
  int build() {
    Future.microtask(_init);
    return kDefaultMaxFolderDepth;
  }

  Future<void> _init() async {
    final db = await ref.read(appDatabaseProvider).database;
    final rows = await db.query('settings', limit: 1);
    if (rows.isNotEmpty) {
      state = rows.first['max_folder_depth'] as int;
    }
  }

  Future<void> setMaxFolderDepth(int value) async {
    final clamped = value.clamp(1, 5);
    final db = await ref.read(appDatabaseProvider).database;
    await db.update('settings', {'max_folder_depth': clamped});
    state = clamped;
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, int>(SettingsNotifier.new);
