import 'package:flutter/foundation.dart';

import '../models/module_model.dart';
import '../data/repositories/module_repository.dart';

class ModuleInfoViewModel with ChangeNotifier {
  final ModuleRepository repository;
  int? moduleId;

  ModuleInfoViewModel({required this.repository});

  void setModule(int id) {
    if (moduleId != id) {
      moduleId = id;
      notifyListeners();
    }
  }

  MarkItem? get module =>
      (moduleId != null) ? repository.modules[moduleId!] : null;

  double get average =>
      (moduleId != null) ? repository.averageMark(moduleId!) : 0;

  void reorderContributors(int oldIndex, int newIndex) {
    final parent = module;
    if (parent != null) {
      repository.reorderContributors(
        parent: parent,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
    }
  }
}
