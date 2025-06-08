import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/degree_repository.dart';
import '../../models/degree_year_model.dart';
import '../../models/module_model.dart';
import 'module_widget.dart';
import 'statistics_carousel_widget.dart';

class DegreeYearWidget extends StatelessWidget {
  final int degreeId;
  final DegreeYear year;

  const DegreeYearWidget({
    super.key,
    required this.degreeId,
    required this.year,
  });

  int _getCrossAxisCount(double width) {
    final count = (width / 160).floor();
    return count > 0 ? count : 1;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DegreeRepository>();
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Year ${year.yearIndex}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Remove Year',
                onPressed: () =>
                    repo.removeYear(degreeId, year.key as int),
              ),
            ],
          ),
        ),
        StatisticsCarousel(
          height: 150,
          items: [
            StatisticItem(
              heading: 'Year ${year.yearIndex} average',
              value: repo.averageForYear(year.key as int),
              isPercentage: true,
            ),
            StatisticItem(
              heading: 'Weighted average',
              value: repo.weightedAverageForYear(year.key as int),
              isPercentage: true,
            ),
            StatisticItem(
              heading: 'Credits',
              value: repo.creditsForYear(year.key as int),
            ),
          ],
        ),
        modulesGrid,
      ],
    );
  }
}
