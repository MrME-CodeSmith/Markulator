import 'package:flutter/foundation.dart';

import '../models/module_model.dart';
import '../data/repositories/module_repository.dart';

class ContributorInfoViewModel with ChangeNotifier {
  final ModuleRepository repository;
  MarkItem? parent;

  ContributorInfoViewModel({required this.repository});

  void setParent(MarkItem item) {
    parent = item;
    notifyListeners();
  }

  void reorderContributors(int oldIndex, int newIndex) {
    if (parent != null) {
      repository.reorderContributors(
        parent: parent!,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
    }
  }
}
