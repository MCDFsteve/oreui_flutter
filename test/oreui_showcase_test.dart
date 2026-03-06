import 'package:flutter_test/flutter_test.dart';

import 'package:oreui_flutter/oreui_flutter.dart';

void main() {
  testWidgets('OreShowcasePage renders without exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OreShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Ore UI Showcase'), findsOneWidget);
    expect(find.text('Buttons'), findsOneWidget);
    expect(find.text('Form'), findsOneWidget);
    expect(find.text('Toggles'), findsOneWidget);
    expect(find.byType(OreDropdownButton<String>), findsOneWidget);
    expect(find.text('选项一'), findsWidgets);
  });
}
