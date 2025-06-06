import 'package:flutter/material.dart';
import 'package:markulator/Screens/contributor_information_screen.dart';
import 'package:markulator/Screens/module_information_screen.dart';
import 'package:markulator/Screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'Screens/dev_test_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './Providers/cloud_provider.dart';

import './Model/module_model.dart';
import './Screens/overview_screen.dart';
import './Providers/module_provider.dart';
import './Providers/system_information_provider.dart';
import './Providers/settings_provider.dart';

const userModulesBox = "UserModules";
const moduleContributorsBox = "ModuleContributors";
const syncInfoBox = "SyncInfo";
const settingsBox = "Settings";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(MarkItemAdapter());

  await Hive.openBox(
    userModulesBox,
    compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
  );
  await Hive.openBox(syncInfoBox);
  await Hive.openBox(settingsBox);

  final ModuleProvider moduleProvider = ModuleProvider();
  final CloudProvider cloudProvider = CloudProvider();
  final SettingsProvider settingsProvider =
      SettingsProvider(cloudProvider: cloudProvider);
  await moduleProvider.setCloudProvider(cloudProvider);

  runApp(
    Markulator(
      moduleProvider: moduleProvider,
      cloudProvider: cloudProvider,
      settingsProvider: settingsProvider,
    ),
  );
}

class Markulator extends StatelessWidget {
  const Markulator({
    super.key,
    required this.moduleProvider,
    required this.cloudProvider,
    required this.settingsProvider,
  });

  final ModuleProvider moduleProvider;
  final CloudProvider cloudProvider;
  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemInformationProvider>(
          create: (context) => SystemInformationProvider(),
        ),
        ChangeNotifierProvider<ModuleProvider>(create: (_) => moduleProvider),
        ChangeNotifierProvider<CloudProvider>(create: (_) => cloudProvider),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Markulator',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
            ),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const OverviewScreen(),
          routes: {
            ModuleInformationScreen.routeName: ((context) =>
                const ModuleInformationScreen()),
            ContributorInformationScreen.routeName: ((context) =>
                const ContributorInformationScreen()),
            SettingsScreen.routeName: ((context) => const SettingsScreen()),
            if (!kReleaseMode)
              DevTestScreen.routeName: ((context) => const DevTestScreen()),
          },
        ),
      ),
    );
  }
}
