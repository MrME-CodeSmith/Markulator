import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/module_model.dart';
import '../view_models/module_info_view_model.dart';
import 'widgets/add_contributor_pop_up_modal_widget.dart';
import 'widgets/statistics_carousel_widget.dart';
import 'widgets/contributor_widget.dart';
import 'widgets/padded_list_heading_widget.dart';
import 'widgets/module_creation_user_input.dart';

class ModuleInformationScreen extends StatelessWidget {
  static const routeName = "/moduleInformation";
  const ModuleInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ModuleInfoViewModel>(context);
    final int moduleName = ModalRoute.of(context)!.settings.arguments as int;
    vm.setModule(moduleName);
    final Widget content = LayoutBuilder(
      builder: (ctx, constraints) {
        final double chartHeight = constraints.maxHeight * 0.4;
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: chartHeight,
              child: StatisticsCarousel(
                height: chartHeight,
                items: [
                  StatisticItem(
                    heading: "${vm.module!.name} average",
                    value: vm.average,
                    isPercentage: true,
                  ),
                  ...vm.module!.contributors.cast<MarkItem>().map(
                    (c) => StatisticItem(
                      heading: c.name,
                      value: c.mark,
                      isPercentage: true,
                    ),
                  ),
                ],
              ),
            ),
            if (vm.module!.contributors.isNotEmpty)
              const PaddedListHeadingWidget(headingName: "Contributors"),
            if (vm.module!.contributors.isNotEmpty)
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    vm.reorderContributors(oldIndex, newIndex);
                  },
                  itemCount: vm.module!.contributors.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      key: ValueKey(vm.module!.contributors[index].key),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ContributorWidget(
                        contributor:
                            (vm.module!.contributors[index]) as MarkItem,
                      ),
                    );
                  },
                ),
              ),
            if (vm.module!.contributors.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No Contributors available.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            vm.module!.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (ctx) => Material(
                      child: ModuleCreationUserInputWidget(toEdit: vm.module!),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.pencil),
              ),
              AddContributorPopUpModal(parent: vm.module!, toEdit: null),
            ],
          ),
        ),
        child: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          vm.module!.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.zero,
                    top: Radius.circular(14),
                  ),
                ),
                builder: (ctx) =>
                    ModuleCreationUserInputWidget(toEdit: vm.module!),
              );
            },
          ),
          AddContributorPopUpModal(parent: vm.module!, toEdit: null),
        ],
      ),
      body: content,
    );
  }
}
