import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/presentation/notes/widgets/note_body_field.dart';
import 'package:notes/presentation/settings/providers/settings_provider.dart';

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this._state);
  final SettingsState _state;

  @override
  SettingsState build() => _state;

  @override
  Future<void> setBodyFontSize(int value) async {
    state = state.copyWith(bodyFontSize: value.clamp(10, 32));
  }
}

Widget _buildField(int fontSize) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith(
        () => FakeSettingsNotifier(SettingsState(bodyFontSize: fontSize)),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: NoteBodyField(
          controller: TextEditingController(),
          onChanged: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('NoteBodyField uses bodyFontSize from settingsProvider',
      (tester) async {
    await tester.pumpWidget(_buildField(24));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byKey(const Key('note_body_field')));
    expect(textField.style?.fontSize, 24.0);
  });

  testWidgets('NoteBodyField re-renders when bodyFontSize changes',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith(
          () => FakeSettingsNotifier(const SettingsState(bodyFontSize: 16)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: NoteBodyField(
              controller: TextEditingController(),
              onChanged: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    var textField = tester.widget<TextField>(find.byKey(const Key('note_body_field')));
    expect(textField.style?.fontSize, 16.0);

    container.read(settingsProvider.notifier).setBodyFontSize(28);
    await tester.pump();

    textField = tester.widget<TextField>(find.byKey(const Key('note_body_field')));
    expect(textField.style?.fontSize, 28.0);
  });
}
