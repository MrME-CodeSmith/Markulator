import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:markulator/Screens/contributor_information_screen.dart';
import 'package:provider/provider.dart';

import '../Model/module_model.dart';
import '../Providers/module_provider.dart';
import '../Providers/system_information_provider.dart';
import './percentage_indicator_widget.dart';
import 'contributor_creation_user_input_widget.dart';

class ContributorWidget extends StatefulWidget {
  const ContributorWidget({
    super.key,
    required this.contributor,
  });

  final MarkItem contributor;

  @override
  State<ContributorWidget> createState() => _ContributorWidgetState();
}

class _ContributorWidgetState extends State<ContributorWidget> {
  late ModuleProvider provider;
  late SystemInformationProvider systemInformationProvider;
  late double screenHeight;
  bool shouldDelete = false;

  @override
  void didChangeDependencies() {
    provider = Provider.of<ModuleProvider>(context, listen: false);
    systemInformationProvider = Provider.of<SystemInformationProvider>(context);
    screenHeight = systemInformationProvider.androidAvailableScreenHeight(
        context: context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.blueGrey[300]!,
                  blurRadius: 2.5,
                  offset: const Offset(5.0, 7.0)),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Slidable(
              key: ValueKey(widget.contributor),
              endActionPane: ActionPane(
                extentRatio: 0.5,
                motion: DrawerMotion(
                  key: widget.key,
                ),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          isDismissible: true,
                          context: context,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                            bottom: Radius.zero,
                            top: Radius.circular(14),
                          )),
                          builder: (ctx) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: ContributorCreationUserInputWidget(
                                  screenHeight: 0,
                                  screenWidth: MediaQuery.of(ctx).size.width,
                                  parent: null,
                                  toEdit: widget.contributor,
                                ),
                              ));
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                              "Do you want to remove this iem with all its sub-contents?"),
                          actions: [
                            TextButton.icon(
                              icon: const Icon(Icons.cancel_rounded),
                              label: const Text("No"),
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.check_rounded),
                              label: const Text("Yes"),
                              onPressed: () {
                                shouldDelete = true;
                                Navigator.of(ctx).pop(false);
                              },
                            ),
                          ],
                        ),
                      ).then((value) {
                        if (shouldDelete) {
                          shouldDelete = false;
                          provider.removeContributor(
                            parent: widget.contributor.parent!,
                            contributor: widget.contributor,
                          );
                        }
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const PercentageIndicatorWidget(
                    percentage: 0,
                    indicatorSize: Size.small,
                  ).getColor(widget.contributor.mark, ColorType.progressColor),
                  foregroundColor: Colors.white,
                  child: ((widget.contributor.mark * 100) % 1 == 0)
                      ? FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                              "${(widget.contributor.mark * 100).toStringAsFixed(0)}%"),
                        )
                      : FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                              "${(widget.contributor.mark * 100).toStringAsFixed(2)}%"),
                        ),
                ),
                title: Text(
                  widget.contributor.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.contributor.contributors.isNotEmpty)
                      (widget.contributor.contributors.length > 1)
                          ? Text(
                              "${widget.contributor.contributors.length} contributors")
                          : Text(
                              "${widget.contributor.contributors.length} contributor",
                            ),
                    SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const ImageIcon(
                            AssetImage('lib/assets/icons/weight.png'),
                            size: 16,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 7),
                          ),
                          if ((widget.contributor.weight * 100) % 1 != 0)
                            Text(
                              "${(widget.contributor.weight * 100).toStringAsFixed(2)}%",
                            ),
                          if ((widget.contributor.weight * 100) % 1 == 0)
                            Text(
                              "${(widget.contributor.weight * 100).toStringAsFixed(0)}%",
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          ContributorInformationScreen.routeName,
          arguments: widget.contributor,
        );
      },
    );
  }
}
