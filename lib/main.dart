import 'package:flutter/material.dart';
import 'package:markulator/views/contributor_information_screen.dart';
import 'package:markulator/views/module_information_screen.dart';
import 'package:markulator/views/degree_overview_screen.dart';
import 'package:markulator/views/degree_information_screen.dart';
import 'package:markulator/views/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'views/dev_test_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './data/services/auth_service.dart';
import './data/services/cloud_service.dart';
import './data/services/module_service.dart';
import './data/repositories/module_repository.dart';
import './data/repositories/degree_repository.dart';

import './models/module_model.dart';
import './models/degree_year_model.dart';
import './models/degree_model.dart';
import './data/services/system_information_service.dart';
import './data/repositories/settings_repository.dart';
import './view_models/overview_view_model.dart';
import './view_models/module_info_view_model.dart';
import './view_models/degree_overview_view_model.dart';
import './view_models/degree_info_view_model.dart';
import './view_models/contributor_info_view_model.dart';
import './view_models/settings_view_model.dart';

const userModulesBox = "UserModules";
const moduleContributorsBox = "ModuleContributors";
const syncInfoBox = "SyncInfo";
const settingsBox = "Settings";
const degreesBox = "Degrees";
const degreeYearsBox = "DegreeYears";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(MarkItemAdapter());
  Hive.registerAdapter(DegreeYearAdapter());
  Hive.registerAdapter(DegreeAdapter());

  await Hive.openBox(
    userModulesBox,
    compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
  );
  await Hive.openBox(degreeYearsBox);
  await Hive.openBox(degreesBox);
  await Hive.openBox(syncInfoBox);
  await Hive.openBox(settingsBox);

  // Instantiate repositories and services first so they can be passed to
  // the view models below.
  final ModuleRepository moduleRepository = ModuleRepository();
  final DegreeRepository degreeRepository = DegreeRepository(
    moduleRepository: moduleRepository,
  );
  final AuthService authService = AuthService();
  final CloudService cloudService = CloudService();

  final ModuleService moduleService = ModuleService(cloudService: cloudService);
  final SettingsRepository settingsRepository = SettingsRepository(
    cloudService: cloudService,
  );

  await moduleRepository.setModuleService(moduleService);
  await degreeRepository.setModuleService(moduleService);

  final SystemInformationService systemInfoProvider =
      SystemInformationService();

  runApp(
    Markulator(
      moduleRepository: moduleRepository,
      degreeRepository: degreeRepository,
      cloudService: cloudService,
      authService: authService,
      settingsRepository: settingsRepository,
      systemInfoProvider: systemInfoProvider,
    ),
  );
}

class Markulator extends StatelessWidget {
  const Markulator({
    super.key,
    required this.moduleRepository,
    required this.degreeRepository,
    required this.cloudService,
    required this.authService,
    required this.settingsRepository,
    required this.systemInfoProvider,
  });

  final ModuleRepository moduleRepository;
  final DegreeRepository degreeRepository;
  final CloudService cloudService;
  final AuthService authService;
  final SettingsRepository settingsRepository;
  final SystemInformationService systemInfoProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemInformationService>.value(
          value: systemInfoProvider,
        ),
        ChangeNotifierProvider<ModuleRepository>.value(value: moduleRepository),
        ChangeNotifierProvider<DegreeRepository>.value(value: degreeRepository),
        ChangeNotifierProvider<CloudService>.value(value: cloudService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<SettingsRepository>.value(
          value: settingsRepository,
        ),
        ChangeNotifierProvider<OverviewViewModel>(
          create: (_) => OverviewViewModel(
            moduleRepository: moduleRepository,
            systemInfoProvider: systemInfoProvider,
          ),
        ),
        ChangeNotifierProvider<ModuleInfoViewModel>(
          create: (_) => ModuleInfoViewModel(repository: moduleRepository),
        ),
        ChangeNotifierProvider<DegreeOverviewViewModel>(
          create: (_) => DegreeOverviewViewModel(
            repository: degreeRepository,
          ),
        ),
        ChangeNotifierProvider<DegreeInfoViewModel>(
          create: (_) => DegreeInfoViewModel(repository: degreeRepository),
        ),
        ChangeNotifierProvider<ContributorInfoViewModel>(
          create: (_) => ContributorInfoViewModel(repository: moduleRepository),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(
            cloudService: cloudService,
            authService: authService,
            modules: moduleRepository,
            settings: settingsRepository,
          ),
        ),
      ],
      child: Consumer<SettingsRepository>(
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
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const DegreeOverviewScreen(),
          routes: {
            DegreeOverviewScreen.routeName: ((context) =>
                const DegreeOverviewScreen()),
            DegreeInformationScreen.routeName: ((context) =>
                const DegreeInformationScreen()),
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
