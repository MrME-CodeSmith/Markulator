import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../main.dart';
import '../services/cloud_service.dart';

class SettingsRepository with ChangeNotifier {
  final CloudService cloudService;
  late final Box _settingsBox;
  bool _darkMode = false;

  SettingsRepository({required this.cloudService}) {
    _settingsBox = Hive.box(settingsBox);
    _darkMode = _settingsBox.get('darkMode', defaultValue: false) as bool;

    // Listen for auth or cloud changes to fetch settings from the cloud
    cloudService.addListener(_handleCloudChange);
  }

  bool get darkMode => _darkMode;

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _settingsBox.put('darkMode', value);
    notifyListeners();
    await cloudService.syncSettings({'darkMode': value});
  }

  Future<void> _handleCloudChange() async {
    if (cloudService.user != null && cloudService.cloudEnabled) {
      final data = await cloudService.fetchSettings();
      if (data != null && data['darkMode'] is bool) {
        final bool newValue = data['darkMode'] as bool;
        if (newValue != _darkMode) {
          _darkMode = newValue;
          await _settingsBox.put('darkMode', newValue);
          notifyListeners();
        }
      }
    }
  }
}
