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

const userModulesBox = "UserModules";
const moduleContributorsBox = "ModuleContributors";
const syncInfoBox = "SyncInfo";

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

  final ModuleProvider moduleProvider = ModuleProvider();
  final CloudProvider cloudProvider = CloudProvider();
  await moduleProvider.setCloudProvider(cloudProvider);

  runApp(
    Markulator(moduleProvider: moduleProvider, cloudProvider: cloudProvider),
  );
}

class Markulator extends StatelessWidget {
  const Markulator({
    super.key,
    required this.moduleProvider,
    required this.cloudProvider,
  });

  final ModuleProvider moduleProvider;
  final CloudProvider cloudProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemInformationProvider>(
          create: (context) => SystemInformationProvider(),
        ),
        ChangeNotifierProvider<ModuleProvider>(create: (_) => moduleProvider),
        ChangeNotifierProvider<CloudProvider>(create: (_) => cloudProvider),
      ],
      child: MaterialApp(
        title: 'Markulator',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
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
    );
  }
}
