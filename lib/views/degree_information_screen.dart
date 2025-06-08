import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/degree_repository.dart';
import '../models/degree_year_model.dart';
import 'widgets/statistics_carousel_widget.dart';
import 'widgets/degree_creation_dialog.dart';
import 'widgets/degree_year_widget.dart';

class DegreeInformationScreen extends StatelessWidget {
  static const routeName = '/degreeInformation';
  const DegreeInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DegreeRepository>();
    final int degreeId = ModalRoute.of(context)!.settings.arguments as int;
    final degree = repo.degrees[degreeId]!;

    final List<Widget> yearWidgets = degree.years
        .cast<DegreeYear>()
        .map((year) => DegreeYearWidget(degreeId: degreeId, year: year))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(degree.name, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Year',
            onPressed: () => repo.addYear(degreeId),
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 0) {
                showDialog(
                  context: context,
                  builder: (ctx) => DegreeCreationDialog(
                    title: 'Rename Degree',
                    confirmText: 'Save',
                    initialName: degree.name,
                    onSubmit: (name) => repo.renameDegree(degreeId, name),
                  ),
                );
              } else if (value == 1) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Are you sure?',
                        style: Theme.of(context).textTheme.bodyMedium),
                    content: Text(
                      'Remove ${degree.name} with all its years?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('No',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      TextButton(
                        onPressed: () {
                          repo.removeDegree(degreeId);
                          Navigator.of(ctx)
                              ..pop()
                              ..pop();
                        },
                        child: Text('Yes',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rename',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const Icon(Icons.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remove',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          StatisticsCarousel(
            height: 150,
            items: [
              StatisticItem(
                heading: '${degree.name} average',
                value: repo.averageForDegree(degreeId),
                isPercentage: true,
              ),
              StatisticItem(
                heading: 'Weighted average',
                value: repo.weightedAverageForDegree(degreeId),
                isPercentage: true,
              ),
              StatisticItem(
                heading: 'Credits',
                value: repo.creditsForDegree(degreeId),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...yearWidgets,
        ],
      ),
    );
  }
}
