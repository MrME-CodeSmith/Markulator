import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/module_model.dart';
import '../Providers/module_provider.dart';
import '../Widgets/add_contributor_pop_up_modal_widget.dart';
import '../Widgets/average_percentage_widget.dart';
import '../Widgets/contributor_widget.dart';
import '../Widgets/padded_list_heading_widget.dart';
import '../Widgets/module_creation_user_input.dart';

class ModuleInformationScreen extends StatefulWidget {
  static const routeName = "/moduleInformation";
  const ModuleInformationScreen({super.key});

  @override
  State<ModuleInformationScreen> createState() =>
      _ModuleInformationScreenState();
}

class _ModuleInformationScreenState extends State<ModuleInformationScreen> {
  late ModuleProvider moduleProvider;
  late int moduleName;

  @override
  void didChangeDependencies() {
    moduleName = ModalRoute.of(context)!.settings.arguments as int;
    moduleProvider = Provider.of<ModuleProvider>(context);
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
                percentage: moduleProvider.averageMark(moduleName),
                heading: "${moduleProvider.modules[moduleName]!.name} average",
              ),
            ),
            if (moduleProvider.modules[moduleName]!.contributors.isNotEmpty)
              const PaddedListHeadingWidget(headingName: "Contributors"),
            if (moduleProvider.modules[moduleName]!.contributors.isNotEmpty)
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    moduleProvider.reorderContributors(
                      parent: moduleProvider.modules[moduleName]!,
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    );
                  },
                  itemCount:
                      moduleProvider.modules[moduleName]!.contributors.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      key: ValueKey(
                        moduleProvider
                            .modules[moduleName]!
                            .contributors[index]
                            .key,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ContributorWidget(
                        contributor:
                            (moduleProvider
                                    .modules[moduleName]!
                                    .contributors[index])
                                as MarkItem,
                      ),
                    );
                  },
                ),
              ),
            if (moduleProvider.modules[moduleName]!.contributors.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No Contributors available.",
                    style: TextStyle(fontSize: 18),
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
          middle: Text(moduleProvider.modules[moduleName]!.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (ctx) => Material(
                      child: ModuleCreationUserInputWidget(
                        toEdit: moduleProvider.modules[moduleName]!,
                      ),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.pencil),
              ),
              AddContributorPopUpModal(
                parent: moduleProvider.modules[moduleName]!,
                toEdit: null,
              ),
            ],
          ),
        ),
        child: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(moduleProvider.modules[moduleName]!.name),
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
                builder: (ctx) => ModuleCreationUserInputWidget(
                  toEdit: moduleProvider.modules[moduleName]!,
                ),
              );
            },
          ),
          AddContributorPopUpModal(
            parent: moduleProvider.modules[moduleName]!,
            toEdit: null,
          ),
        ],
      ),
      body: content,
    );
  }
}
