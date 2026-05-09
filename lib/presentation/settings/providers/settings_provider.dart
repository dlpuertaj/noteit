import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/data/app_database.dart';
import 'package:notes/utils/constants.dart';

class SettingsState {
  const SettingsState({
    this.maxFolderDepth = kDefaultMaxFolderDepth,
    this.bodyFontSize = kDefaultBodyFontSize,
  });

  final int maxFolderDepth;
  final int bodyFontSize;

  SettingsState copyWith({int? maxFolderDepth, int? bodyFontSize}) {
    return SettingsState(
      maxFolderDepth: maxFolderDepth ?? this.maxFolderDepth,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    Future.microtask(_init);
    return const SettingsState();
  }

  Future<void> _init() async {
    final db = await ref.read(appDatabaseProvider).database;
    final rows = await db.query('settings', limit: 1);
    if (rows.isNotEmpty) {
      state = SettingsState(
        maxFolderDepth: rows.first['max_folder_depth'] as int,
        bodyFontSize: rows.first['body_font_size'] as int,
      );
    }
  }

  Future<void> setMaxFolderDepth(int value) async {
    final clamped = value.clamp(1, 5);
    final db = await ref.read(appDatabaseProvider).database;
    await db.update('settings', {'max_folder_depth': clamped});
    state = state.copyWith(maxFolderDepth: clamped);
  }

  Future<void> setBodyFontSize(int value) async {
    final clamped = value.clamp(10, 32);
    final db = await ref.read(appDatabaseProvider).database;
    await db.update('settings', {'body_font_size': clamped});
    state = state.copyWith(bodyFontSize: clamped);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
