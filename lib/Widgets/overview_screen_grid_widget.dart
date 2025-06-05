import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../Providers/module_provider.dart';
import './module_widget.dart';
import 'overview_screen_no_modules_available_widget.dart';
import 'padded_list_heading_widget.dart';

class OverviewScreenGridWidget extends StatelessWidget {
  const OverviewScreenGridWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ModuleProvider moduleProvider = Provider.of<ModuleProvider>(context);
    return (moduleProvider.modules.isNotEmpty)
        ? Column(
            children: [
              const PaddedListHeadingWidget(headingName: "Modules"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ReorderableGridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (_, i) => Container(
                      key: ValueKey(moduleProvider.modules.keys.elementAt(i)),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blueGrey[300]!,
                              blurRadius: 2.5,
                              offset: const Offset(5.0, 7.0)),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ModuleWidget(
                          id: moduleProvider.modules.entries
                              .elementAt(i)
                              .value
                              .key),
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
          )
        : const OverviewScreenNoModulesAvailable();
  }
}
