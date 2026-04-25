import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';
import 'package:notes/presentation/settings/screens/settings_screen.dart';

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this._initial);
  final int _initial;

  int? savedValue;

  @override
  int build() => _initial;

  @override
  Future<void> setMaxFolderDepth(int value) async {
    savedValue = value;
    state = value;
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

Widget _buildApp(int depth,
    {FakeSettingsNotifier? notifier, GoRouter? router}) {
  final fake = notifier ?? FakeSettingsNotifier(depth);
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(() => fake),
    ],
    child: MaterialApp.router(routerConfig: router ?? _testRouter()),
  );
}

void main() {
  testWidgets('screen shows current maxFolderDepth value', (tester) async {
    await tester.pumpWidget(_buildApp(2));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('increasing the value saves the new value', (tester) async {
    final notifier = FakeSettingsNotifier(2);
    await tester.pumpWidget(_buildApp(2, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Increase'));
    await tester.pump();

    expect(notifier.savedValue, 3);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('decreasing the value saves the new value', (tester) async {
    final notifier = FakeSettingsNotifier(2);
    await tester.pumpWidget(_buildApp(2, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();

    expect(notifier.savedValue, 1);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('value is clamped at minimum 1', (tester) async {
    final notifier = FakeSettingsNotifier(1);
    await tester.pumpWidget(_buildApp(1, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();

    expect(notifier.savedValue, isNull);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('value is clamped at maximum 5', (tester) async {
    final notifier = FakeSettingsNotifier(5);
    await tester.pumpWidget(_buildApp(5, notifier: notifier));
    await tester.pump();

    await tester.tap(find.byTooltip('Increase'));
    await tester.pump();

    expect(notifier.savedValue, isNull);
    expect(find.text('5'), findsOneWidget);
  });

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

    await tester.pumpWidget(_buildApp(2, router: router));
    await tester.pump();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Note Editor'), findsOneWidget);
  });
}
