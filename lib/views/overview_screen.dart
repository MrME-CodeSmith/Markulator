import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/overview_view_model.dart';
import 'widgets/module_creation_user_input.dart';
import 'widgets/overview_screen_grid_widget.dart';
import 'widgets/overview_screen_average_carousel_widget.dart';
import 'settings_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<OverviewViewModel>(context);
    vm.initialize(context);
    final Widget body = LayoutBuilder(
      builder: (ctx, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final double carouselHeight = isWide
            ? constraints.maxHeight
            : constraints.maxHeight * 0.4;
        final carousel = OverviewScreenAverageCarouselWidget(
          height: carouselHeight,
          scrollDirection: isWide ? Axis.vertical : Axis.horizontal,
        );

        return isWide
            ? Row(
                children: [
                  Expanded(flex: 2, child: carousel),
                  const Expanded(flex: 3, child: OverviewScreenGridWidget()),
                ],
              )
            : Column(
                children: [
                  carousel,
                  const Expanded(child: OverviewScreenGridWidget()),
                ],
              );
      },
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Markulator',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
            child: const Icon(CupertinoIcons.settings),
          ),
        ),
        child: Stack(
          children: [
            SafeArea(child: body),
            Positioned(
              bottom: 16,
              right: 16,
              child: CupertinoButton.filled(
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (ctx) => Material(
                      child: ModuleCreationUserInputWidget(toEdit: null),
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.add),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Markulator',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
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
            builder: (ctx) => const ModuleCreationUserInputWidget(toEdit: null),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Add Module',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
