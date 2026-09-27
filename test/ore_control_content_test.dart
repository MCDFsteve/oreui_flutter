import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oreui_flutter/oreui_flutter.dart';

const label = '钻石 gyp';

Widget host(Widget control, {double scale = 1, bool dark = false}) =>
    MaterialApp(
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        extensions: [dark ? OreThemeData.dark() : OreThemeData.light()],
      ),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Center(child: SizedBox(width: 340, child: control)),
        ),
      ),
    );

void expectCompleteLabels(WidgetTester tester, String text) {
  for (final element in find.text(text).evaluate()) {
    final paragraph = element.findRenderObject()! as RenderParagraph;
    final requiredHeight = paragraph.getMaxIntrinsicHeight(
      paragraph.size.width,
    );
    expect(
      paragraph.size.height,
      greaterThanOrEqualTo(requiredHeight - 0.01),
      reason: 'The entire line must fit, including CJK glyphs and descenders.',
    );
  }
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('natural-width buttons keep their size on every shadow side', (
    tester,
  ) async {
    for (final side in OreShadowSide.values) {
      final axis = [OreShadowSide.left, OreShadowSide.right].contains(side)
          ? Axis.horizontal
          : Axis.vertical;
      await tester.pumpWidget(
        host(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OreButton(
                key: ValueKey(side),
                onPressed: () {},
                shadowSide: side,
                pressedAxis: axis,
                leading: const Icon(Icons.save),
                child: const Text(label),
              ),
            ],
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      final before = tester.getRect(find.byType(OreButton));
      final gesture = await tester.startGesture(before.center);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expectCompleteLabels(tester, label);
      expect(tester.getRect(find.byType(OreButton)), before);
      await gesture.cancel();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('long dropdown menus open above and scroll to a selection', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 260,
              child: OreDropdownButton<String>(
                value: '0',
                items: List.generate(
                  20,
                  (i) => OreDropdownItem(
                    value: '$i',
                    child: Text('选项 $i：中文介绍与下行字母 gyp，需要折行的文字'),
                  ),
                ),
                onChanged: (value) => selected = value,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byType(OreDropdownButton<String>);
    final top = tester.getTopLeft(button).dy;
    await tester.tap(button);
    await tester.pumpAndSettle();
    final menu = find.byType(SingleChildScrollView);
    expect(tester.getBottomRight(menu).dy, lessThanOrEqualTo(top + 2));
    const text = '选项 19：中文介绍与下行字母 gyp，需要折行的文字';
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    expectCompleteLabels(tester, text);
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
    expect(selected, '19');
    expect(tester.takeException(), isNull);
  });

  for (final size in OreButtonSize.values) {
    for (final scale in [1.0, 1.4, 2.0]) {
      testWidgets(
        'button $size at $scale keeps text and bounds while pressed',
        (tester) async {
          for (final axis in Axis.values) {
            await tester.pumpWidget(
              host(
                OreButton(
                  key: ValueKey('$axis'),
                  size: size,
                  pressedAxis: axis,
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text(label),
                ),
                scale: scale,
                dark: axis == Axis.horizontal,
              ),
            );
            await tester.pumpAndSettle();
            final bounds = tester.getRect(find.byType(OreButton));
            expect(bounds.height, lessThan(140));
            expectCompleteLabels(tester, label);
            final gesture = await tester.startGesture(bounds.center);
            await tester.pump(const Duration(milliseconds: 300));
            await tester.pumpAndSettle();
            expectCompleteLabels(tester, label);
            expect(
              tester.getRect(find.byType(OreButton)),
              bounds,
              reason: 'Pressing must not shift surrounding controls.',
            );
            await gesture.cancel();
            await tester.pumpAndSettle();
          }
        },
      );

      testWidgets(
        'dropdown $size at $scale preserves pressed and menu labels',
        (tester) async {
          String? selected;
          await tester.pumpWidget(
            host(
              OreDropdownButton<String>(
                size: size,
                value: 'diamond',
                items: const [
                  OreDropdownItem(value: 'diamond', child: Text(label)),
                  OreDropdownItem(value: 'free', child: Text('免费 gyp')),
                ],
                onChanged: (value) => selected = value,
              ),
              scale: scale,
              dark: true,
            ),
          );
          await tester.pumpAndSettle();
          final bounds = tester.getRect(find.byType(OreDropdownButton<String>));
          expect(bounds.height, lessThan(140));
          expectCompleteLabels(tester, label);
          final gesture = await tester.startGesture(bounds.center);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();
          expectCompleteLabels(tester, label);
          expect(
            tester.getRect(find.byType(OreDropdownButton<String>)),
            bounds,
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expectCompleteLabels(tester, label);
          expectCompleteLabels(tester, '免费 gyp');
          await tester.tap(find.text('免费 gyp'));
          await tester.pumpAndSettle();
          expect(selected, 'free');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
