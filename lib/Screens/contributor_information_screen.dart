import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/module_model.dart';
import '../view_models/contributor_info_view_model.dart';
import '../Widgets/add_contributor_pop_up_modal_widget.dart';
import '../Widgets/average_percentage_widget.dart';
import '../Widgets/contributor_widget.dart';
import '../Widgets/padded_list_heading_widget.dart';
import '../Widgets/contributor_creation_user_input_widget.dart';

class ContributorInformationScreen extends StatelessWidget {
  static const routeName = "/ContributorInformation";
  const ContributorInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ContributorInfoViewModel>(context);
    final MarkItem parentArg =
        ModalRoute.of(context)!.settings.arguments as MarkItem;
    vm.setParent(parentArg);
    final Widget content = LayoutBuilder(
      builder: (ctx, constraints) {
        final double chartHeight = constraints.maxHeight * 0.4;
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: chartHeight,
              child: AveragePercentageWidget(
                percentage: vm.parent!.mark,
                heading: "${vm.parent!.name} average",
              ),
            ),
            if (vm.parent!.contributors.isNotEmpty)
              const PaddedListHeadingWidget(headingName: "Contributors"),
            if (vm.parent!.contributors.isNotEmpty)
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    vm.reorderContributors(oldIndex, newIndex);
                  },
                  itemCount: vm.parent!.contributors.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      key: ValueKey(vm.parent!.contributors[index].key),
                      padding: (index < (vm.parent!.contributors.length - 1))
                          ? const EdgeInsets.only(bottom: 12)
                          : const EdgeInsets.all(0),
                      child: ContributorWidget(
                        contributor:
                            (vm.parent!.contributors[index] as MarkItem),
                      ),
                    );
                  },
                ),
              ),
            if (vm.parent!.contributors.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No contributors specified.",
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
            vm.parent!.name,
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
                      child: ContributorCreationUserInputWidget(
                        screenHeight: 0,
                        screenWidth: MediaQuery.of(ctx).size.width,
                        parent: null,
                        toEdit: vm.parent!,
                      ),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.pencil),
              ),
              AddContributorPopUpModal(parent: vm.parent!, toEdit: null),
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
          vm.parent!.name,
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
                builder: (ctx) => ContributorCreationUserInputWidget(
                  screenHeight: 0,
                  screenWidth: MediaQuery.of(ctx).size.width,
                  parent: null,
                  toEdit: vm.parent!,
                ),
              );
            },
          ),
          AddContributorPopUpModal(parent: vm.parent!, toEdit: null),
        ],
      ),
      body: content,
    );
  }
}
