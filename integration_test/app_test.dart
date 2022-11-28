import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:markulator/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Create 10 modules with 1 second delay.",
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    final Finder addModuleButton = find.byType(FloatingActionButton);

    for (var i = 0; i < 10; i++) {
      await tester.tap(addModuleButton);
      await tester.pumpAndSettle();

      final Finder addButton = find.byType(ElevatedButton);
      final Finder moduleNameTExtInput = find.byKey(const Key("MN"));
      final Finder markTextInput = find.byKey(const Key("MI"));

      await tester.enterText(moduleNameTExtInput, "test $i");
      await tester.enterText(markTextInput, "60.68");
      await tester.tap(addButton);

      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));
      expect(find.text("test $i"), findsOneWidget);
    }

    await Future.delayed(const Duration(seconds: 20));
  });
}
