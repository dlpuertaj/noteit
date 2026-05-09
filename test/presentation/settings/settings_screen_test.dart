import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';
import 'package:notes/presentation/settings/screens/settings_screen.dart';

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this._initial);
  final SettingsState _initial;

  int? savedMaxDepth;
  int? savedFontSize;

  @override
  SettingsState build() => _initial;

  @override
  Future<void> setMaxFolderDepth(int value) async {
    savedMaxDepth = value;
    state = state.copyWith(maxFolderDepth: value);
  }

  @override
  Future<void> setBodyFontSize(int value) async {
    savedFontSize = value;
    state = state.copyWith(bodyFontSize: value);
  }
}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Note Editor'))),
        ),
      ],
    );

Widget _buildApp({
  int depth = 2,
  int fontSize = 16,
  FakeSettingsNotifier? notifier,
  GoRouter? router,
}) {
  final initial = SettingsState(maxFolderDepth: depth, bodyFontSize: fontSize);
  final fake = notifier ?? FakeSettingsNotifier(initial);
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => fake),
    ],
    child: MaterialApp.router(routerConfig: router ?? _testRouter()),
  );
}

void main() {
  // --- Max folder depth ---

  testWidgets('screen shows current maxFolderDepth value', (tester) async {
    await tester.pumpWidget(_buildApp(depth: 2));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('increasing max depth saves the new value', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 2, bodyFontSize: 16));
    await tester.pumpWidget(_buildApp(depth: 2, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Increase max depth'));
    await tester.pump();

    expect(notifier.savedMaxDepth, 3);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('decreasing max depth saves the new value', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 2, bodyFontSize: 16));
    await tester.pumpWidget(_buildApp(depth: 2, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Decrease max depth'));
    await tester.pump();

    expect(notifier.savedMaxDepth, 1);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('max depth is clamped at minimum 1', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 1, bodyFontSize: 16));
    await tester.pumpWidget(_buildApp(depth: 1, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Decrease max depth'));
    await tester.pump();

    expect(notifier.savedMaxDepth, isNull);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('max depth is clamped at maximum 5', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 5, bodyFontSize: 16));
    await tester.pumpWidget(_buildApp(depth: 5, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Increase max depth'));
    await tester.pump();

    expect(notifier.savedMaxDepth, isNull);
    expect(find.text('5'), findsWidgets);
  });

  // --- Body font size ---

  testWidgets('screen shows current bodyFontSize value', (tester) async {
    await tester.pumpWidget(_buildApp(fontSize: 20));
    await tester.pump();

    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('increasing font size saves the new value', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 2, bodyFontSize: 16));
    await tester.pumpWidget(_buildApp(fontSize: 16, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Increase font size'));
    await tester.pump();

    expect(notifier.savedFontSize, 18);
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('decreasing font size saves the new value', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 2, bodyFontSize: 16));
    await tester.pumpWidget(_buildApp(fontSize: 16, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Decrease font size'));
    await tester.pump();

    expect(notifier.savedFontSize, 14);
    expect(find.text('14'), findsOneWidget);
  });

  testWidgets('font size Decrease disabled at minimum 10', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 2, bodyFontSize: 10));
    await tester.pumpWidget(_buildApp(fontSize: 10, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Decrease font size'));
    await tester.pump();

    expect(notifier.savedFontSize, isNull);
  });

  testWidgets('font size Increase disabled at maximum 32', (tester) async {
    final notifier = FakeSettingsNotifier(
        const SettingsState(maxFolderDepth: 2, bodyFontSize: 32));
    await tester.pumpWidget(_buildApp(fontSize: 32, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Increase font size'));
    await tester.pump();

    expect(notifier.savedFontSize, isNull);
  });

  // --- Navigation ---

  testWidgets('back button navigates back to Note Editor', (tester) async {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Note Editor'))),
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(router: router));
    await tester.pump();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Note Editor'), findsOneWidget);
  });
}
