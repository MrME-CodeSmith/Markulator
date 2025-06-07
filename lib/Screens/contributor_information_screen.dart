import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/module_model.dart';
import '../data/repositories/module_repository.dart';
import '../Widgets/add_contributor_pop_up_modal_widget.dart';
import '../Widgets/average_percentage_widget.dart';
import '../Widgets/contributor_widget.dart';
import '../Widgets/padded_list_heading_widget.dart';
import '../Widgets/contributor_creation_user_input_widget.dart';

class ContributorInformationScreen extends StatefulWidget {
  static const routeName = "/ContributorInformation";
  const ContributorInformationScreen({super.key});

  @override
  State<ContributorInformationScreen> createState() =>
      _ContributorInformationScreenState();
}

class _ContributorInformationScreenState
    extends State<ContributorInformationScreen> {
  late MarkItem parent;
  late ModuleRepository moduleProvider;

  @override
  void didChangeDependencies() {
    parent = ModalRoute.of(context)!.settings.arguments as MarkItem;
    moduleProvider = Provider.of<ModuleRepository>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = LayoutBuilder(
      builder: (ctx, constraints) {
        final double chartHeight = constraints.maxHeight * 0.4;
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: chartHeight,
              child: AveragePercentageWidget(
                percentage: parent.mark,
                heading: "${parent.name} average",
              ),
            ),
            if (parent.contributors.isNotEmpty)
              const PaddedListHeadingWidget(headingName: "Contributors"),
            if (parent.contributors.isNotEmpty)
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    moduleProvider.reorderContributors(
                      parent: parent,
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    );
                  },
                  itemCount: parent.contributors.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      key: ValueKey(parent.contributors[index].key),
                      padding: (index < (parent.contributors.length - 1))
                          ? const EdgeInsets.only(bottom: 12)
                          : const EdgeInsets.all(0),
                      child: ContributorWidget(
                        contributor: (parent.contributors[index] as MarkItem),
                      ),
                    );
                  },
                ),
              ),
            if (parent.contributors.isEmpty)
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
            parent.name,
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
                        toEdit: parent,
                      ),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.pencil),
              ),
              AddContributorPopUpModal(parent: parent, toEdit: null),
            ],
          ),
        ),
        child: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(parent.name, style: Theme.of(context).textTheme.bodyMedium),
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
                  toEdit: parent,
                ),
              );
            },
          ),
          AddContributorPopUpModal(parent: parent, toEdit: null),
        ],
      ),
      body: content,
    );
  }
}
