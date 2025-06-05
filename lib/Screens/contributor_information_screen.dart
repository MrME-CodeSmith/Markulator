import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/module_model.dart';
import '../Providers/module_provider.dart';
import '../Providers/system_information_provider.dart';
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

  late SystemInformationProvider systemInformationProvider;
  late SystemInformationProvider symoduleProviderstemInformationProvider;
  late ModuleProvider moduleProvider;

  @override
  void didChangeDependencies() {
    systemInformationProvider = Provider.of<SystemInformationProvider>(context);
    parent = ModalRoute.of(context)!.settings.arguments as MarkItem;
    moduleProvider = Provider.of<ModuleProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(parent.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.zero, top: Radius.circular(14)),
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
          AddContributorPopUpModal(
            parent: parent,
            toEdit: null,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: systemInformationProvider.androidAvailableScreenHeight(
                    context: context) *
                0.4,
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
                        contributor: (parent.contributors[index] as MarkItem)),
                  );
                },
              ),
            ),
          if (parent.contributors.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "No contributors specified.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
