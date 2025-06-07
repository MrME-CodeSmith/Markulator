import 'package:flutter/material.dart';

import 'percentage_indicator_widget.dart';

class AveragePercentageWidget extends StatelessWidget {
  const AveragePercentageWidget({
    super.key,
    required this.percentage,
    required this.heading,
  });

  final double percentage;
  final String heading;

  String _classificationText() {
    final value = percentage * 100;
    if (value >= 70) return 'First class';
    if (value >= 60) return 'Upper second (2:1)';
    if (value >= 50) return 'Lower second (2:2)';
    if (value >= 40) return 'Third class';
    return 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 7),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey[300]!,
                  blurRadius: 2.5,
                  offset: const Offset(5.0, 7.0),
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Card(
              clipBehavior: Clip.hardEdge,
              shadowColor: Theme.of(context).colorScheme.primary,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
              child: GridTile(
                header: GridTileBar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  title: Text(
                    heading,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                footer: GridTileBar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  title: Text(
                    _classificationText(),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: constraints.maxHeight * 0.3),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 400,
                    ),
                    child: PercentageIndicatorWidget(
                      percentage: percentage,
                      indicatorSize: Size.large,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
