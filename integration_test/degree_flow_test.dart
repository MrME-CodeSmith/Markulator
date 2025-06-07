import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:markulator/main.dart' as app;
import 'package:markulator/views/degree_overview_screen.dart';
import 'package:markulator/data/repositories/degree_repository.dart';

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

  testWidgets('create degree and verify statistics', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Access repository through provider
    final BuildContext context =
        tester.element(find.byType(DegreeOverviewScreen).first);
    final repo = Provider.of<DegreeRepository>(context, listen: false);
    final int degId = repo.addDegree('Integration Degree');
    final int yearId = repo.addYear(degId);
    repo.addModule(
      degId,
      yearId,
      name: 'Module A',
      mark: 80,
      credits: 10,
    );
    repo.addModule(
      degId,
      yearId,
      name: 'Module B',
      mark: 60,
      credits: 20,
    );

    await tester.pumpAndSettle();

    // Verify degree appears on overview screen
    expect(find.text('Integration Degree'), findsOneWidget);

    // Navigate to degree detail screen
    await tester.tap(find.text('Integration Degree'));
    await tester.pumpAndSettle();

    // Verify statistics widgets by heading text
    expect(find.text('Integration Degree average'), findsOneWidget);
    expect(find.text('Weighted average'), findsWidgets);
    expect(find.text('Credits'), findsWidgets);
  });
}
