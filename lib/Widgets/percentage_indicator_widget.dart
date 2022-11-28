import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../Providers/system_information_provider.dart';

enum ColorType {
  progressColor,
  backgroundColor,
}

enum Size {
  large,
  small,
}

class PercentageIndicatorWidget extends StatelessWidget {
  final double percentage;
  final Size indicatorSize;

  const PercentageIndicatorWidget({
    required this.percentage,
    required this.indicatorSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final systemInformationProvider =
        Provider.of<SystemInformationProvider>(context);
    final screenHeight = systemInformationProvider.androidAvailableScreenHeight(
        context: context);

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: CircularPercentIndicator(
              radius: (indicatorSize == Size.small)
                  ? screenHeight * 0.05
                  : screenHeight * 0.14,
              lineWidth: (indicatorSize == Size.small)
                  ? screenHeight * 0.013
                  : screenHeight * 0.03,
              percent: percentage,
              progressColor: getColor(percentage, ColorType.progressColor),
              backgroundColor:
                  (getColor(percentage, ColorType.backgroundColor))!,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1250,
              arcType: (indicatorSize == Size.large) ? ArcType.HALF : null,
              arcBackgroundColor: (indicatorSize == Size.large)
                  ? getColor(percentage, ColorType.backgroundColor)
                  : null,
            ),
          ),
        ),
        Center(
          child: getText(),
        )
      ],
    );
  }

  Text getText() {
    if ((percentage * 100) % 1 > 0) {
      return Text(
        "${(percentage * 100).toStringAsFixed(2)}%",
        style: (indicatorSize == Size.small)
            ? const TextStyle(fontSize: 12, color: Colors.black)
            : const TextStyle(fontSize: 25, color: Colors.black),
      );
    } else {
      return Text(
        "${(percentage * 100).toInt().toString()}%",
        style: (indicatorSize == Size.small)
            ? const TextStyle(fontSize: 12, color: Colors.black)
            : const TextStyle(fontSize: 25, color: Colors.black),
      );
    }
  }

  Color? getColor(double percentage, ColorType type) {
    switch (type) {
      case ColorType.progressColor:
        {
          if (percentage == 1.0) {
            return const Color.fromARGB(255, 212, 175, 55);
          } else if (percentage >= 0.75) {
            return Colors.purple[500];
          } else if ((percentage >= 0.5)) {
            return Colors.green[500];
          }
          return Colors.red[500];
        }
      default:
        {
          if (percentage >= 0.75) {
            return Colors.purple[100];
          } else if ((percentage >= 0.5)) {
            return Colors.green[100];
          }
          return Colors.red[100];
        }
    }
  }
}
