import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/degree_repository.dart';
import 'degree_information_screen.dart';
import 'widgets/statistics_carousel_widget.dart';
import 'widgets/degree_creation_dialog.dart';

class DegreeOverviewScreen extends StatelessWidget {
  static const routeName = '/degrees';
  const DegreeOverviewScreen({super.key});

  int _getCrossAxisCount(double width) {
    final count = (width / 160).floor();
    return count > 0 ? count : 1;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DegreeRepository>();
    final degrees = repo.degrees.entries.toList();

    final carouselHeight = MediaQuery.of(context).size.height * 0.3;

    final carousel = degrees.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            width: double.infinity,
            height: carouselHeight,
            child: PageView(
              children: degrees.map((e) {
                final id = e.key as int;
                return StatisticsCarousel(
                  height: carouselHeight,
                  items: [
                    StatisticItem(
                      heading: '${e.value.name} average',
                      value: repo.averageForDegree(id),
                      isPercentage: true,
                    ),
                    StatisticItem(
                      heading: 'Weighted average',
                      value: repo.weightedAverageForDegree(id),
                      isPercentage: true,
                    ),
                    StatisticItem(
                      heading: 'Credits',
                      value: repo.creditsForDegree(id),
                    ),
                  ],
                );
              }).toList(),
            ),
          );

    final grid = degrees.isEmpty
        ? Center(
            child: Text(
              'No degrees available.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(
                MediaQuery.of(context).size.width,
              ),
              childAspectRatio: 1,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: degrees.length,
            itemBuilder: (ctx, i) {
              final entry = degrees[i];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    DegreeInformationScreen.routeName,
                    arguments: entry.key,
                  );
                },
                child: Card(
                  elevation: 2,
                  child: Center(
                    child: Text(
                      entry.value.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: Text('Degrees', style: Theme.of(context).textTheme.bodyMedium),
      ),
      body: Column(
        children: [
          if (degrees.isNotEmpty) carousel,
          Expanded(
            child: Padding(padding: const EdgeInsets.all(8), child: grid),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => DegreeCreationDialog(
              title: 'Create Degree',
              confirmText: 'Add',
              onSubmit: repo.addDegree,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text('Add Degree',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
