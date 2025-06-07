import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../data/repositories/module_repository.dart';
import './module_widget.dart';
import 'overview_screen_no_modules_available_widget.dart';
import 'padded_list_heading_widget.dart';

class OverviewScreenGridWidget extends StatelessWidget {
  const OverviewScreenGridWidget({super.key});

  int _getCrossAxisCount(double width) {
    final count = (width / 160).floor();
    return (count > 0) ? count : 1;
  }

  @override
  Widget build(BuildContext context) {
    final ModuleRepository moduleProvider = Provider.of<ModuleRepository>(
      context,
    );
    return (moduleProvider.modules.isNotEmpty)
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: [
                  const PaddedListHeadingWidget(headingName: "Modules"),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: ReorderableGridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(
                            constraints.maxWidth,
                          ),
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 20,
                        ),
                        itemBuilder: (_, i) => ModuleWidget(
                          key: ValueKey(
                            moduleProvider.modules.keys.elementAt(i),
                          ),
                          id: moduleProvider.modules.entries
                              .elementAt(i)
                              .value
                              .key,
                        ),
                        itemCount: moduleProvider.modules.entries.length,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        onReorder: (oldIndex, newIndex) {
                          moduleProvider.reorderModules(oldIndex, newIndex);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        : const OverviewScreenNoModulesAvailable();
  }
}
