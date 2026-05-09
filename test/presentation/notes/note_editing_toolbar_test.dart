import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/presentation/notes/widgets/note_editing_toolbar.dart';

Widget _buildToolbar({
  required int bodyFontSize,
  VoidCallback? onDecreaseFontSize,
  VoidCallback? onIncreaseFontSize,
}) {
  final controller = UndoHistoryController();
  final notifier = ValueNotifier<UndoHistoryController>(controller);

  return MaterialApp(
    home: Scaffold(
      body: NoteEditingToolbar(
        activeUndoNotifier: notifier,
        onUndo: () {},
        onRedo: () {},
        bodyFontSize: bodyFontSize,
        onDecreaseFontSize: onDecreaseFontSize ?? () {},
        onIncreaseFontSize: onIncreaseFontSize ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('Decrease font button is disabled at minimum (10)', (tester) async {
    await tester.pumpWidget(_buildToolbar(bodyFontSize: 10));

    final decreaseButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.text_decrease),
    );
    expect(decreaseButton.onPressed, isNull);
  });

  testWidgets('Increase font button is disabled at maximum (32)', (tester) async {
    await tester.pumpWidget(_buildToolbar(bodyFontSize: 32));

    final increaseButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.text_increase),
    );
    expect(increaseButton.onPressed, isNull);
  });

  testWidgets('tapping Increase calls onIncreaseFontSize', (tester) async {
    bool called = false;
    await tester.pumpWidget(_buildToolbar(
      bodyFontSize: 16,
      onIncreaseFontSize: () => called = true,
    ));

    await tester.tap(find.byTooltip('Increase font size'));
    expect(called, isTrue);
  });

  testWidgets('tapping Decrease calls onDecreaseFontSize', (tester) async {
    bool called = false;
    await tester.pumpWidget(_buildToolbar(
      bodyFontSize: 16,
      onDecreaseFontSize: () => called = true,
    ));

    await tester.tap(find.byTooltip('Decrease font size'));
    expect(called, isTrue);
  });
}
