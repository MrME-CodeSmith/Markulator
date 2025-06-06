import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
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
    gridItemWidth =
        (MediaQuery.of(context).size.width / _getCrossAxisCount(context)) - 20;
    moduleProvider = Provider.of<ModuleProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final module = moduleProvider.modules[widget.id]!;
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(ModuleInformationScreen.routeName, arguments: widget.id);
      },
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        shadowColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                    child: PercentageIndicatorWidget(
                      percentage: module.mark,
                      indicatorSize: Size.small,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        module.credits.toStringAsFixed(
                          module.credits % 1 == 0 ? 0 : 1,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(top: 0, right: 0, child: _buildMenuButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.ellipsis_vertical),
        onPressed: () => _showCupertinoMenu(),
      );
    }
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 0) {
          _openEdit();
        } else if (value == 1) {
          confirmDeletion(context, moduleProvider);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (moduleProvider.modules[widget.id]!.contributors.isNotEmpty)
                  ? const Text('Rename')
                  : const Text('Edit'),
              const Icon(Icons.edit_rounded),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remove'),
              Icon(
                Icons.delete_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCupertinoMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openEdit();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (moduleProvider.modules[widget.id]!.contributors.isNotEmpty)
                    ? const Text('Rename')
                    : const Text('Edit'),
                const Icon(CupertinoIcons.pencil),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              confirmDeletion(context, moduleProvider);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Remove'),
                Icon(CupertinoIcons.delete_solid),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _openEdit() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => Material(
          child: ModuleCreationUserInputWidget(
            toEdit: moduleProvider.modules[widget.id],
          ),
        ),
      );
    } else {
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
          toEdit: moduleProvider.modules[widget.id],
        ),
      );
    }
  }

  void confirmDeletion(BuildContext context, ModuleProvider moduleProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text(
          "Do you want to remove ${moduleProvider.modules[widget.id]!.name} with all its sub-contents?",
        ),
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
