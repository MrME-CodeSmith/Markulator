import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/module_repository.dart';
import './average_percentage_widget.dart';

class OverviewScreenAverageCarouselWidget extends StatefulWidget {
  final double height;
  final Axis scrollDirection;
  const OverviewScreenAverageCarouselWidget({
    super.key,
    required this.height,
    this.scrollDirection = Axis.horizontal,
  });

  @override
  State<OverviewScreenAverageCarouselWidget> createState() =>
      _OverviewScreenAverageCarouselWidgetState();
}

class _OverviewScreenAverageCarouselWidgetState
    extends State<OverviewScreenAverageCarouselWidget> {
  late PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModuleRepository moduleProvider = Provider.of<ModuleRepository>(
      context,
    );
    final bool showBoth =
        widget.scrollDirection == Axis.vertical && widget.height > 370;
    final List<Widget> indicators = List.generate(
      2,
      (i) => Container(
        margin: const EdgeInsets.all(4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (_index == i)
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
      ),
    );

    final pageView = Expanded(
      child: PageView(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        onPageChanged: (i) {
          setState(() {
            _index = i;
          });
        },
        children: [
          AveragePercentageWidget(
            percentage: moduleProvider.averageModulesMark,
            heading: 'Modules average',
          ),
          AveragePercentageWidget(
            percentage: moduleProvider.weightedAverageModulesMark,
            heading: 'Weighted average',
          ),
        ],
      ),
    );

    final indicatorWidget = widget.scrollDirection == Axis.vertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: indicators,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: indicators,
          );

    if (showBoth) {
      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: Column(
          children: [
            Expanded(
              child: AveragePercentageWidget(
                percentage: moduleProvider.averageModulesMark,
                heading: 'Modules average',
              ),
            ),
            Expanded(
              child: AveragePercentageWidget(
                percentage: moduleProvider.weightedAverageModulesMark,
                heading: 'Weighted average',
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: widget.scrollDirection == Axis.vertical
          ? Row(
              children: [
                pageView,
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: indicatorWidget,
                ),
              ],
            )
          : Column(children: [pageView, indicatorWidget]),
    );
  }
}
