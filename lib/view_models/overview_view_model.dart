import 'package:flutter/widgets.dart';

import '../Providers/system_information_provider.dart';
import '../data/repositories/module_repository.dart';
import '../Model/module_model.dart';

class OverviewViewModel with ChangeNotifier {
  final ModuleRepository moduleRepository;
  final SystemInformationProvider systemInfoProvider;

  OverviewViewModel({
    required this.moduleRepository,
    required this.systemInfoProvider,
  });

  void initialize(BuildContext context) {
    systemInfoProvider.initialize(context);
  }

  Map<int, MarkItem> get modules => moduleRepository.modules;
  double get averageModulesMark => moduleRepository.averageModulesMark;
  double get weightedAverageModulesMark =>
      moduleRepository.weightedAverageModulesMark;

  void reorderModules(int oldIndex, int newIndex) {
    moduleRepository.reorderModules(oldIndex, newIndex);
  }
}
