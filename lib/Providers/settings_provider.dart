import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import 'cloud_provider.dart';

class SettingsProvider with ChangeNotifier {
  final CloudProvider cloudProvider;
  late final Box _settingsBox;
  bool _darkMode = false;

  SettingsProvider({required this.cloudProvider}) {
    _settingsBox = Hive.box(settingsBox);
    _darkMode = _settingsBox.get('darkMode', defaultValue: false) as bool;

    // Listen for auth or cloud changes to fetch settings from the cloud
    cloudProvider.addListener(_handleCloudChange);
  }

  bool get darkMode => _darkMode;

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _settingsBox.put('darkMode', value);
    notifyListeners();
    await cloudProvider.syncSettings({'darkMode': value});
  }

  Future<void> _handleCloudChange() async {
    if (cloudProvider.user != null && cloudProvider.cloudEnabled) {
      final data = await cloudProvider.fetchSettings();
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
