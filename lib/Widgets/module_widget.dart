import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/module_provider.dart';
import '../Providers/system_information_provider.dart';
import '../Screens/module_information_screen.dart';
import 'module_creation_user_input.dart';
import 'percentage_indicator_widget.dart';

class ModuleWidget extends StatefulWidget {
  final int id;

  const ModuleWidget({super.key, required this.id});

  @override
  State<ModuleWidget> createState() => _ModuleWidgetState();
}

class _ModuleWidgetState extends State<ModuleWidget> {
  late SystemInformationProvider systemInformationProvider;

  late double screenHeight;

  late double gridItemWidth;

  late ModuleProvider moduleProvider;

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  void didChangeDependencies() {
    screenHeight = MediaQuery.of(context).size.height;
    gridItemWidth = (MediaQuery.of(context).size.width / _getCrossAxisCount(context)) - 20;
    moduleProvider = Provider.of<ModuleProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      footer: SizedBox(
        height: gridItemWidth * 0.3,
        child: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  (moduleProvider.modules[widget.id]!.contributors.isNotEmpty)
                      ? const Text("Rename")
                      : const Text("Edit"),
                  const Icon(Icons.edit_rounded),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(seconds: 0),
                  () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.zero, top: Radius.circular(14)),
                    ),
                    builder: (ctx) => ModuleCreationUserInputWidget(
                      toEdit: moduleProvider.modules[widget.id],
                    ),
                  ),
                );
              },
            ),
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Remove"),
                  Icon(Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.error),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(seconds: 0),
                  () => confirmDeletion(context, moduleProvider),
                );
              },
            ),
          ],
          padding: EdgeInsets.only(left: gridItemWidth - 40),
        ),
      ),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        shadowColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: GestureDetector(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (screenHeight * 0.14 > 300)
                      ? 300
                      : screenHeight * 0.14,
                  maxWidth: 400,
                  minHeight: 10,
                  minWidth: double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: PercentageIndicatorWidget(
                    percentage: moduleProvider.modules[widget.id]!.mark,
                    indicatorSize: Size.small,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    moduleProvider.modules[widget.id]!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              ModuleInformationScreen.routeName,
              arguments: widget.id,
            );
          },
        ),
      ),
    );
  }

  void confirmDeletion(BuildContext context, ModuleProvider moduleProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text(
            "Do you want to remove ${moduleProvider.modules[widget.id]!.name} with all its sub-contents?"),
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
              moduleProvider.removeModule(key: widget.id);
              Navigator.of(ctx).pop(false);
            },
          ),
        ],
      ),
    );
  }
}
