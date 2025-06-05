import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/module_provider.dart';
import './average_percentage_widget.dart';

class OverviewScreenAverageCarouselWidget extends StatefulWidget {
  const OverviewScreenAverageCarouselWidget({super.key});

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
    final ModuleProvider moduleProvider = Provider.of<ModuleProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
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
            ),
          )
        ],
      ),
    );
  }
}
