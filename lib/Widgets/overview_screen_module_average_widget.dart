import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/module_provider.dart';
import './average_percentage_widget.dart';

class OverviewScreenModuleAverageWidget extends StatelessWidget {
  const OverviewScreenModuleAverageWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ModuleProvider moduleProvider = Provider.of<ModuleProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      child: AveragePercentageWidget(
        percentage: moduleProvider.averageModulesMark,
        heading: "Modules average",
      ),
    );
  }
}
