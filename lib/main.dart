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
import './data/services/auth_service.dart';
import './data/services/cloud_service.dart';
import './data/services/module_service.dart';
import './data/repositories/module_repository.dart';

import './Model/module_model.dart';
import './Screens/overview_screen.dart';
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

  final authService = AuthService();
  final cloudService = CloudService();
  final moduleService = ModuleService(cloudService: cloudService);
  final ModuleRepository moduleProvider = ModuleRepository();
  final SettingsProvider settingsProvider = SettingsProvider(
    cloudService: cloudService,
  );
  await moduleProvider.setModuleService(moduleService);

  runApp(
    Markulator(
      moduleProvider: moduleProvider,
      cloudService: cloudService,
      authService: authService,
      settingsProvider: settingsProvider,
    ),
  );
}

class Markulator extends StatelessWidget {
  const Markulator({
    super.key,
    required this.moduleProvider,
    required this.cloudService,
    required this.authService,
    required this.settingsProvider,
  });

  final ModuleRepository moduleProvider;
  final CloudService cloudService;
  final AuthService authService;
  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemInformationProvider>(
          create: (context) => SystemInformationProvider(),
        ),
        ChangeNotifierProvider<ModuleRepository>(create: (_) => moduleProvider),
        ChangeNotifierProvider<CloudService>(create: (_) => cloudService),
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => settingsProvider,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Markulator',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
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
