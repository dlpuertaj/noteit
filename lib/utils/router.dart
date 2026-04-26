import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/export/screens/export_bottom_sheet.dart';
import 'package:notes/presentation/notes/screens/note_editor_screen.dart';
import 'package:notes/presentation/search/screens/search_results_screen.dart';
import 'package:notes/presentation/settings/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const NoteEditorScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (_, _) => const SearchResultsScreen(),
    ),
    GoRoute(
      path: '/export',
      pageBuilder: (_, state) => _BottomSheetPage(
        key: state.pageKey,
        child: const ExportBottomSheet(),
      ),
    ),
  ],
);

class _BottomSheetPage<T> extends Page<T> {
  const _BottomSheetPage({required this.child, super.key});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: false,
      builder: (_) => child,
    );
  }
}
