import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/module_model.dart';
import '../Providers/module_provider.dart';
import '../Providers/system_information_provider.dart';
import '../Widgets/add_contributor_pop_up_modal_widget.dart';
import '../Widgets/average_percentage_widget.dart';
import '../Widgets/contributor_widget.dart';
import '../Widgets/padded_list_heading_widget.dart';

class ModuleInformationScreen extends StatefulWidget {
  static const routeName = "/moduleInformation";
  const ModuleInformationScreen({super.key});

  @override
  State<ModuleInformationScreen> createState() =>
      _ModuleInformationScreenState();
}

class _ModuleInformationScreenState extends State<ModuleInformationScreen> {
  late SystemInformationProvider systemInformationProvider;
  late double screenHeight;
  late ModuleProvider moduleProvider;
  late int moduleName;

  @override
  void didChangeDependencies() {
    moduleName = ModalRoute.of(context)!.settings.arguments as int;
    systemInformationProvider = Provider.of<SystemInformationProvider>(context);

    screenHeight = systemInformationProvider.androidAvailableScreenHeight(
        context: context);
    moduleProvider = Provider.of<ModuleProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(moduleProvider.modules[moduleName]!.name),
        actions: [
          AddContributorPopUpModal(
            parent: moduleProvider.modules[moduleName]!,
            toEdit: null,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.4,
            child: AveragePercentageWidget(
              percentage: moduleProvider.averageMark(moduleName),
              heading: "${moduleProvider.modules[moduleName]!.name} average",
            ),
          ),
          if (moduleProvider.modules[moduleName]!.contributors.isNotEmpty)
            const PaddedListHeadingWidget(headingName: "Contributors"),
          if (moduleProvider.modules[moduleName]!.contributors.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount:
                    moduleProvider.modules[moduleName]?.contributors.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ContributorWidget(
                        contributor: (moduleProvider.modules[moduleName]!
                            .contributors[index]) as MarkItem),
                  );
                },
              ),
            ),
          if (moduleProvider.modules[moduleName]!.contributors.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "No Contributors available.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
