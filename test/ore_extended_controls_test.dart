import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oreui_flutter/oreui_flutter.dart';

Widget host(Widget child, {bool dark = false}) => MaterialApp(
  theme: oreAppTheme(brightness: dark ? Brightness.dark : Brightness.light),
  scrollBehavior: const OreScrollBehavior(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('loading buttons use Ore assets and cannot activate', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: OreButton(
            isLoading: true,
            onPressed: () => presses++,
            child: const Text('保存'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('保存'));
    expect(presses, 0);
    expect(find.byType(OreLoadingIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).package, 'oreui_flutter');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('calendar respects leap days, bounds and year/month navigation', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 340,
            child: OreCalendarDatePicker(
              initialDate: DateTime(2024, 2, 15),
              firstDate: DateTime(2024, 2, 10),
              lastDate: DateTime(2025, 3, 20),
              onDateChanged: (d) => selected = d,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('ore-date-2024-2-9')));
    expect(selected, isNull);
    await tester.tap(find.byKey(const ValueKey('ore-date-2024-2-29')));
    expect(selected, DateTime(2024, 2, 29));
    expect(find.byKey(const ValueKey('ore-date-2024-2-30')), findsNothing);
    final previous = tester.widget<OreIconButton>(
      find.byWidgetPredicate((w) => w is OreIconButton && w.tooltip == '上个月'),
    );
    expect(previous.onPressed, isNull);
    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2025'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ore-date-2025-2-29')), findsNothing);
    await tester.tap(
      find.byWidgetPredicate((w) => w is OreIconButton && w.tooltip == '下个月'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ore-date-2025-3-21')));
    expect(selected, DateTime(2024, 2, 29));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'checkbox/radio rows wrap labels and support keyboard selection',
    (tester) async {
      var checked = false;
      String? choice;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 240,
              child: Column(
                children: [
                  OreCheckboxListTile(
                    value: checked,
                    onChanged: (v) => setState(() => checked = v!),
                    title: const Text('这是一个需要在窄屏换行的很长的选项名称'),
                    subtitle: const Text('说明'),
                  ),
                  OreRadioListTile<String>(
                    value: 'one',
                    groupValue: choice,
                    onChanged: (v) => setState(() => choice = v),
                    title: const Text('作品一'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(checked, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(choice, 'one');
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byType(Radio<String>), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('icon action retains keyboard activation with no container', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var count = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: OreIconButton(
            focusNode: focus,
            icon: const Icon(Icons.close),
            onPressed: () => count++,
          ),
        ),
        dark: true,
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(count, 1);
    expect(
      find.descendant(
        of: find.byType(OreIconButton),
        matching: find.byType(OreSurface),
      ),
      findsNothing,
    );
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('dialog uses Ore controls and returns the selected result', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => OreButton(
            child: const Text('打开'),
            onPressed: () async {
              result = await showOreDialog<String>(
                context: context,
                builder: (context) => OreAlertDialog(
                  title: const Text('确认'),
                  content: const OreTextField(hintText: '填写名称'),
                  actions: [
                    OreButton(
                      onPressed: () => Navigator.pop(context, 'saved'),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(find.byType(OreAlertDialog), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    await tester.enterText(find.byType(TextField), '作品');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(result, 'saved');
    expect(tester.takeException(), isNull);
  });

  testWidgets('toast replaces old messages, closes, and releases its timer', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    showOreToast(context, const Text('已保存'));
    await tester.pump();
    showOreToast(context, const Text('已提交'));
    await tester.pump();
    expect(find.text('已保存'), findsNothing);
    expect(find.text('已提交'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('已提交'), findsNothing);
    showOreToast(context, const Text('处理中'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('text editing uses Ore selection controls and copy menu', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'abcdef');
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(OreTextField(controller: controller)));
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.selectionControls, isA<OreTextSelectionControls>());
    await tester.tap(find.byType(TextField));
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 3);
    await tester.pump();
    final state = tester.state<EditableTextState>(find.byType(EditableText));
    state.showToolbar();
    await tester.pumpAndSettle();
    expect(find.byType(OreTextSelectionToolbar), findsOneWidget);
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.byType(OreTextSelectionToolbar), findsNothing);
    expect(controller.text, 'abcdef');
  });
}
