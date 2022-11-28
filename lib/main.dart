import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markulator/Screens/contributor_information_screen.dart';
import 'package:markulator/Screens/module_information_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './Model/module_model.dart';
import './Screens/overview_screen.dart';
import './Providers/module_provider.dart';
import './Providers/system_information_provider.dart';

const userModulesBox = "UserModules";
const moduleContributorsBox = "ModuleContributors";

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MarkItemAdapter());

  await Hive.openBox(
    userModulesBox,
    compactionStrategy: (entries, deletedEntries) => deletedEntries > 20,
  );

  final ModuleProvider moduleProvider = ModuleProvider();

  runApp(Markulator(
    moduleProvider: moduleProvider,
  ));
}

class Markulator extends StatelessWidget {
  const Markulator({Key? key, required this.moduleProvider}) : super(key: key);

  final ModuleProvider moduleProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemInformationProvider>(
          create: (context) => SystemInformationProvider(),
        ),
        ChangeNotifierProvider<ModuleProvider>(
          create: (_) => moduleProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Markulator',
        theme: ThemeData(
            colorScheme:
                ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)),
        // theme: ThemeData.light()
        // ThemeData(
        //   colorScheme: const ColorScheme(
        //     brightness: Brightness.light,
        //     primary: Color.fromARGB(255, 189, 194, 198),
        //     onPrimary: Colors.white,
        //     secondary: Color.fromARGB(255, 248, 249, 249),
        //     onSecondary: Color.fromARGB(255, 189, 194, 198),
        //     error: Colors.red,
        //     onError: Color.fromARGB(255, 248, 249, 249),
        //     background: Color.fromARGB(255, 214, 218, 220),
        //     onBackground: Color.fromARGB(255, 189, 194, 198),
        //     surface: Color.fromARGB(255, 235, 236, 237),
        //     onSurface: Color.fromARGB(255, 189, 194, 198),
        //   ),
        // ),
        home: const OverviewScreen(),
        routes: {
          ModuleInformationScreen.routeName: ((context) =>
              const ModuleInformationScreen()),
          ContributorInformationScreen.routeName: ((context) =>
              const ContributorInformationScreen()),
        },
      ),
    );
  }
}
