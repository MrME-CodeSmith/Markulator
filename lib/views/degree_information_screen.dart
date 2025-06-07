import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/degree_repository.dart';
import '../models/degree_year_model.dart';
import '../models/module_model.dart';
import 'widgets/average_percentage_widget.dart';
import 'widgets/module_widget.dart';

class DegreeInformationScreen extends StatelessWidget {
  static const routeName = '/degreeInformation';
  const DegreeInformationScreen({super.key});

  int _getCrossAxisCount(double width) {
    final count = (width / 160).floor();
    return count > 0 ? count : 1;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DegreeRepository>();
    final int degreeId = ModalRoute.of(context)!.settings.arguments as int;
    final degree = repo.degrees[degreeId]!;

    final List<Widget> yearWidgets = degree.years.cast<DegreeYear>().map((
      year,
    ) {
      final modules = year.modules.cast<MarkItem>();
      final modulesGrid = modules.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No modules for year ${year.yearIndex}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(
                    MediaQuery.of(context).size.width,
                  ),
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (ctx, idx) {
                  final m = modules.elementAt(idx);
                  return ModuleWidget(id: m.key as int);
                },
              ),
            );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AveragePercentageWidget(
            percentage: repo.weightedAverageForYear(year.key as int),
            heading: 'Year ${year.yearIndex} average',
          ),
          modulesGrid,
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(degree.name, style: Theme.of(context).textTheme.bodyMedium),
      ),
      body: ListView(
        children: [
          AveragePercentageWidget(
            percentage: repo.weightedAverageForDegree(degreeId),
            heading: '${degree.name} average',
          ),
          const SizedBox(height: 12),
          ...yearWidgets,
        ],
      ),
    );
  }
}
