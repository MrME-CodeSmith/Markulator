import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math' as math;

enum ColorType { progressColor, backgroundColor }

enum Size { large, small }

class PercentageIndicatorWidget extends StatelessWidget {
  final double percentage;
  final Size indicatorSize;

  const PercentageIndicatorWidget({
    required this.percentage,
    required this.indicatorSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final shortestSide = math.min(
          constraints.maxHeight,
          constraints.maxWidth,
        );
        final radius = (indicatorSize == Size.small)
            ? shortestSide * 0.4
            : shortestSide * 0.45;
        final lineWidth = (indicatorSize == Size.small)
            ? radius * 0.26
            : radius * 0.22;

        return Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                  maxWidth: 400,
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: CircularPercentIndicator(
                    radius: radius,
                    lineWidth: lineWidth,
                    percent: percentage,
                    progressColor: getColor(
                      percentage,
                      ColorType.progressColor,
                    ),
                    backgroundColor: (getColor(
                      percentage,
                      ColorType.backgroundColor,
                    ))!,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1250,
                    arcType: (indicatorSize == Size.large)
                        ? ArcType.HALF
                        : null,
                    arcBackgroundColor: (indicatorSize == Size.large)
                        ? getColor(percentage, ColorType.backgroundColor)
                        : null,
                  ),
                ),
              ),
            ),
            Center(child: getText(context)),
          ],
        );
      },
    );
  }

  Text getText(BuildContext context) {
    final smallStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Colors.black);
    final largeStyle =
        Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black);

    if ((percentage * 100) % 1 > 0) {
      return Text(
        "${(percentage * 100).toStringAsFixed(2)}%",
        style: (indicatorSize == Size.small) ? smallStyle : largeStyle,
      );
    } else {
      return Text(
        "${(percentage * 100).toInt()}%",
        style: (indicatorSize == Size.small) ? smallStyle : largeStyle,
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
