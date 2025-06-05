import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/system_information_provider.dart';
import '../Widgets/module_creation_user_input.dart';
import '../Widgets/overview_screen_grid_widget.dart';
import '../Widgets/overview_screen_module_average_widget.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<SystemInformationProvider>(context).initialize(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Markulator"),
      ),
      body: const Column(
        children: <Widget>[
          OverviewScreenModuleAverageWidget(),
          OverviewScreenGridWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.zero, top: Radius.circular(14)),
            ),
            builder: (ctx) => const ModuleCreationUserInputWidget(
              toEdit: null,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Module'),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
