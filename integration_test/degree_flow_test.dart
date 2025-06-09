import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:markulator/main.dart' as app;

class _NoopFirebaseCoreHostApi implements TestFirebaseCoreHostApi {
  @override
  Future<PigeonInitializeResponse> initializeApp(
      String appName, PigeonFirebaseOptions options) async {
    return PigeonInitializeResponse(
      name: appName,
      options: options,
      pluginConstants: {},
    );
  }

  @override
  Future<List<PigeonInitializeResponse?>> initializeCore() async => [];

  @override
  Future<PigeonFirebaseOptions> optionsFromResource() async =>
      PigeonFirebaseOptions(
        apiKey: '',
        projectId: '',
        appId: '',
        messagingSenderId: '',
      );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  TestFirebaseCoreHostApi.setup(_NoopFirebaseCoreHostApi());

  testWidgets('create degree using UI controls', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Open add degree dialog and create degree
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Integration Degree');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify degree appears on overview screen
    expect(find.text('Integration Degree'), findsOneWidget);

    // Navigate to degree detail screen
    await tester.tap(find.text('Integration Degree'));
    await tester.pumpAndSettle();

    // Add a year
    await tester.tap(find.byTooltip('Add Year'));
    await tester.pumpAndSettle();
    expect(find.text('Year 1'), findsOneWidget);

    // Add first module
    await tester.tap(find.byTooltip('Add Module'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('MN')), 'Module A');
    await tester.enterText(find.byKey(const Key('MI')), '80');
    await tester.enterText(find.byKey(const Key('MC')), '10');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Add second module
    await tester.tap(find.byTooltip('Add Module'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('MN')), 'Module B');
    await tester.enterText(find.byKey(const Key('MI')), '60');
    await tester.enterText(find.byKey(const Key('MC')), '20');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify modules visible
    expect(find.text('Module A'), findsOneWidget);
    expect(find.text('Module B'), findsOneWidget);

    // Verify statistics widgets by heading text
    expect(find.text('Integration Degree average'), findsOneWidget);
    expect(find.text('Weighted average'), findsWidgets);
    expect(find.text('Credits'), findsWidgets);
  });
}
