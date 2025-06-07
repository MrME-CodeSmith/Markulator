import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:markulator/view_models/settings_view_model.dart';
import 'package:markulator/data/repositories/module_repository.dart';
import 'package:markulator/data/repositories/settings_repository.dart';
import 'package:markulator/data/services/cloud_service.dart';
import 'package:markulator/data/services/auth_service.dart';

class MockCloudService extends Mock implements CloudService {}
class MockAuthService extends Mock implements AuthService {}
class MockModuleRepository extends Mock implements ModuleRepository {}
class MockSettingsRepository extends Mock implements SettingsRepository {}
class FakeBuildContext extends Fake implements BuildContext {}
class FakeUser extends Fake implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeUser());
  });

  late MockCloudService cloud;
  late MockAuthService auth;
  late MockModuleRepository modules;
  late MockSettingsRepository settings;
  late SettingsViewModel viewModel;

  setUp(() {
    cloud = MockCloudService();
    auth = MockAuthService();
    modules = MockModuleRepository();
    settings = MockSettingsRepository();

    when(() => cloud.cloudEnabled).thenReturn(false);
    when(() => settings.darkMode).thenReturn(false);
    when(() => auth.user).thenReturn(null);

    viewModel = SettingsViewModel(
      cloudService: cloud,
      authService: auth,
      modules: modules,
      settings: settings,
    );
  });

  test('exposes values from services', () {
    expect(viewModel.darkMode, false);
    expect(viewModel.cloudEnabled, false);
    expect(viewModel.user, null);
  });

  test('toggleCloud enables cloud and syncs when true', () async {
    when(() => modules.syncOnCloudEnabled(any())).thenAnswer((_) async {});

    await viewModel.toggleCloud(true, FakeBuildContext());

    verify(() => cloud.setCloudEnabled(true)).called(1);
    verify(() => modules.syncOnCloudEnabled(any())).called(1);
  });

  test('toggleCloud disables cloud without syncing when false', () async {
    await viewModel.toggleCloud(false, FakeBuildContext());

    verify(() => cloud.setCloudEnabled(false)).called(1);
    verifyNever(() => modules.syncOnCloudEnabled(any()));
  });

  test('toggleDarkMode forwards to repository', () async {
    when(() => settings.setDarkMode(true)).thenAnswer((_) async {});

    await viewModel.toggleDarkMode(true);

    verify(() => settings.setDarkMode(true)).called(1);
  });

  test('signIn triggers auth and sync when cloud enabled', () async {
    when(() => auth.signInWithGoogle()).thenAnswer((_) async {});
    when(() => cloud.cloudEnabled).thenReturn(true);
    when(() => modules.syncOnCloudEnabled(any())).thenAnswer((_) async {});

    await viewModel.signIn(FakeBuildContext());

    verify(() => auth.signInWithGoogle()).called(1);
    verify(() => modules.syncOnCloudEnabled(any())).called(1);
  });

  test('signOut delegates to auth service', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});

    await viewModel.signOut();

    verify(() => auth.signOut()).called(1);
  });
}
