import 'package:flutter/material.dart';

import 'average_percentage_widget.dart';

class StatisticItem {
  final String heading;
  final double value;
  final bool isPercentage;

  const StatisticItem({
    required this.heading,
    required this.value,
    this.isPercentage = false,
  });
}

class StatisticsCarousel extends StatefulWidget {
  final double height;
  final Axis scrollDirection;
  final List<StatisticItem> items;

  const StatisticsCarousel({
    super.key,
    required this.height,
    required this.items,
    this.scrollDirection = Axis.horizontal,
  });

  @override
  State<StatisticsCarousel> createState() => _StatisticsCarouselState();
}

class _StatisticsCarouselState extends State<StatisticsCarousel> {
  late final PageController _controller;
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
    final showAll =
        widget.scrollDirection == Axis.vertical &&
        widget.height > 370 &&
        widget.items.length <= 2;

    final indicators = List.generate(
      widget.items.length,
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
        children: widget.items.map((item) => _StatisticCard(item)).toList(),
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

    if (showAll) {
      return SizedBox(
        width: double.infinity,
        height: widget.height,
        child: Column(
          children: widget.items
              .map((item) => Expanded(child: _StatisticCard(item)))
              .toList(),
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

class _StatisticCard extends StatelessWidget {
  final StatisticItem item;
  const _StatisticCard(this.item);

  @override
  Widget build(BuildContext context) {
    if (item.isPercentage) {
      return AveragePercentageWidget(
        percentage: item.value,
        heading: item.heading,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
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
                    item.heading,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    item.value % 1 == 0
                        ? item.value.toInt().toString()
                        : item.value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium,
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
