import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/services/cloud_service.dart';
import '../data/services/auth_service.dart';
import '../data/repositories/module_repository.dart';
import '../Providers/settings_provider.dart';

class SettingsViewModel with ChangeNotifier {
  final CloudService cloudService;
  final AuthService authService;
  final ModuleRepository modules;
  final SettingsProvider settings;

  SettingsViewModel({
    required this.cloudService,
    required this.authService,
    required this.modules,
    required this.settings,
  }) {
    cloudService.addListener(_forwardNotify);
    authService.addListener(_forwardNotify);
    settings.addListener(_forwardNotify);
  }

  void _forwardNotify() => notifyListeners();

  bool get darkMode => settings.darkMode;
  bool get cloudEnabled => cloudService.cloudEnabled;
  User? get user => authService.user;

  Future<void> toggleCloud(bool value, dynamic context) async {
    cloudService.setCloudEnabled(value);
    if (value) await modules.syncOnCloudEnabled(context);
  }

  Future<void> toggleDarkMode(bool value) => settings.setDarkMode(value);

  Future<void> signIn(dynamic context) async {
    await authService.signInWithGoogle();
    if (cloudEnabled) {
      await modules.syncOnCloudEnabled(context);
    }
  }

  Future<void> signOut() => authService.signOut();
}
