import 'package:flutter/material.dart';

import 'percentage_indicator_widget.dart';

class AveragePercentageWidget extends StatelessWidget {
  const AveragePercentageWidget({
    Key? key,
    required this.percentage,
    required this.heading,
  }) : super(key: key);

  final double percentage;
  final String heading;

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
                    offset: const Offset(5.0, 7.0)),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Card(
              clipBehavior: Clip.hardEdge,
              shadowColor: Theme.of(context).colorScheme.primary,
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21)),
              child: GridTile(
                header: GridTileBar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  title: Text(
                    heading,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: constraints.maxHeight * 0.3),
                  child: PercentageIndicatorWidget(
                    percentage: percentage,
                    indicatorSize: Size.large,
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
