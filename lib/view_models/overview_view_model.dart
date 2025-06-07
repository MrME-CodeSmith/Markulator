import 'package:flutter/widgets.dart';

import '../data/services/system_information_service.dart';
import '../data/repositories/module_repository.dart';
import '../models/module_model.dart';

class OverviewViewModel with ChangeNotifier {
  final ModuleRepository moduleRepository;
  final SystemInformationService systemInfoProvider;

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
