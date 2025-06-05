import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Model/module_model.dart';
import '../main.dart';

class ModuleProvider with ChangeNotifier {
  late final dynamic _storedModules;
  late final Map<dynamic, dynamic> _modules;

  ModuleProvider() {
    _storedModules = Hive.box(userModulesBox);
    _modules = _storedModules.toMap();

    _modules.removeWhere((key, value) => value.parent != null);

    _modules.forEach((key, value) => setAppropriateParent(value));
  }

  Map<int, MarkItem> get modules {
    return {..._modules};
  }

  double get averageModulesMark {
    double total = 0;

    _modules.forEach((key, value) {
      total += value.mark;
    });
    if (total > 0) {
      total /= _modules.length;
    }

    return total;
  }

  double get weightedAverageModulesMark {
    double weightedTotal = 0;
    double creditsTotal = 0;

    _modules.forEach((key, value) {
      weightedTotal += value.mark * value.credits;
      creditsTotal += value.credits;
    });

    if (creditsTotal > 0) {
      return weightedTotal / creditsTotal;
    }

    return 0;
  }

  double averageMark(int id) {
    MarkItem? m = _modules[id];
    return (m != null) ? m.mark : 0;
  }

  void addContributor({
    required MarkItem parent,
    required String contributorName,
    required double weight,
    required double mark,
    required bool autoWeight,
  }) {
    MarkItem toAdd = MarkItem(
      name: contributorName,
      weight: weight / 100,
      mark: mark / 100,
      contributors: HiveList(_storedModules),
      parent: parent,
      autoWeight: autoWeight,
      credits: 0,
    );

    _storedModules.add(toAdd);

    toAdd.save();

    parent.contributors.add(toAdd);

    calculateWeights(parent);

    notifyListeners();

    parent.save();
  }

  void updateContributor({
    required int key,
    required MarkItem parent,
    required String contributorName,
    required double weight,
    required double mark,
    required bool autoWeight,
  }) {
    int index = parent.contributors.indexWhere((element) => element.key == key);

    (parent.contributors[index] as MarkItem).name = contributorName;
    (parent.contributors[index] as MarkItem).mark = mark /= 100;
    (parent.contributors[index] as MarkItem).autoWeight = autoWeight;
    (parent.contributors[index] as MarkItem).weight = weight /= 100;

    calculateWeights(parent);

    notifyListeners();

    parent.contributors[index].save();
  }

  void calculateWeights(MarkItem parent) {
    List<MarkItem> weightedList = [], unweightedList = [];

    for (var i = 0; i < parent.contributors.length; i++) {
      MarkItem currentContributor = (parent.contributors[i] as MarkItem);
      if (!currentContributor.autoWeight) {
        weightedList.add(currentContributor);
      } else {
        unweightedList.add(currentContributor);
      }
    }

    parent.mark = 0;
    double totalWeight = 0;
    for (var i = 0; i < weightedList.length; i++) {
      MarkItem c = weightedList.elementAt(i);
      totalWeight += (c.weight * 100);
      parent.mark += (c.mark * 100) * c.weight;
    }

    double remainingWeight = (100 - totalWeight) / unweightedList.length;
    for (var i = 0; i < unweightedList.length; i++) {
      MarkItem c = unweightedList.elementAt(i);
      c.weight = max((remainingWeight / 100), 0);
      c.save();
      parent.mark += (c.mark * 100) * c.weight;
    }

    parent.mark /= 100;

    parent.save();

    if (parent.parent != null) {
      calculateWeights(parent.parent!);
    }
  }

  void addModule({
    required String name,
    required double mark,
    required HiveList? contributors,
    required double credits,
  }) {
    MarkItem m = MarkItem(
      name: name,
      mark: mark /= 100,
      contributors:
          (contributors != null) ? contributors : HiveList(_storedModules),
      autoWeight: true,
      parent: null,
      weight: 0,
      credits: credits,
    );

    _storedModules.add(m);

    m.save();

    _modules.putIfAbsent(m.key, () => m);

    notifyListeners();
  }

  void removeContributor({
    required MarkItem parent,
    required MarkItem contributor,
  }) {
    _storedModules.delete(contributor.key);

    calculateWeights(parent);

    notifyListeners();
  }

  void removeModule({required int key}) {
    _modules.remove(key);

    notifyListeners();

    _storedModules.delete(key);
  }

  void updateModule({
    required int id,
    required String name,
    required double mark,
    required double credits,
  }) {
    _modules[id]!.name = name;
    // Only update the mark if the module has no contributors. When a module
    // contains contributors its mark is calculated automatically based on its
    // children, therefore it should remain untouched here.
    if (_modules[id]!.contributors.isEmpty) {
      _modules[id]!.mark = mark / 100;
    }
    _modules[id]!.credits = credits;
    notifyListeners();

    _modules[id]!.save();
  }

  void setAppropriateParent(MarkItem parent) {
    parent.contributors.toList().forEach((element) {
      (element as MarkItem).parent = parent;
      setAppropriateParent(element);
    });
  }

  void reorderModules(int oldIndex, int newIndex) {
    final entries = _modules.entries.toList();
    final entry = entries.removeAt(oldIndex);
    entries.insert(newIndex, entry);
    _modules
      ..clear()
      ..addEntries(entries);
    notifyListeners();
  }

  void reorderContributors(
      {required MarkItem parent, required int oldIndex, required int newIndex}) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = parent.contributors.removeAt(oldIndex) as MarkItem;
    parent.contributors.insert(newIndex, item);
    parent.save();
    notifyListeners();
  }
}
