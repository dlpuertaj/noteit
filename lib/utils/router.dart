import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _PlaceholderScreen(name: 'Note Editor'),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const _PlaceholderScreen(name: 'Settings'),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const _PlaceholderScreen(name: 'Search Results'),
    ),
    GoRoute(
      path: '/export',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: _PlaceholderScreen(name: 'Export'),
      ),
    ),
    GoRoute(
      path: '/folders/picker',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: _PlaceholderScreen(name: 'Folder Picker'),
      ),
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text(name)),
    );
  }
}
