import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Model/module_model.dart';
import '../main.dart';
import 'cloud_provider.dart';

class ModuleProvider with ChangeNotifier {
  late final dynamic _storedModules;
  late final Map<dynamic, dynamic> _modules;
  late final Box _syncBox;
  CloudProvider? _cloudProvider;

  ModuleProvider() {
    _storedModules = Hive.box(userModulesBox);
    _syncBox = Hive.box(syncInfoBox);
    _modules = _storedModules.toMap();

    _modules.removeWhere((key, value) => value.parent != null);

    _modules.forEach((key, value) => setAppropriateParent(value));
  }

  DateTime? get localLastUpdated =>
      _syncBox.get('localLastUpdated') as DateTime?;

  void _updateLocalLastUpdated([DateTime? time]) {
    _syncBox.put('localLastUpdated', time ?? DateTime.now());
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

  Future<void> setCloudProvider(CloudProvider provider) async {
    _cloudProvider = provider;
    final data = await provider.fetchModulesIfNewer();
    if (data != null) {
      await _loadFromRemote(data, provider.lastUpdated);
      notifyListeners();
    }
  }

  void _sync() {
    _updateLocalLastUpdated();
    if (_cloudProvider != null) {
      _cloudProvider!.syncModules(
        _modules.values.map((e) => (e as MarkItem).toMap()).toList(),
      );
    }
  }

  Future<void> _loadFromRemote(
    List<Map<String, dynamic>> data, [
    DateTime? remoteTime,
  ]) async {
    _modules.clear();
    await _storedModules.clear();
    for (final map in data) {
      final item = MarkItem.fromMap(map, _storedModules);
      _modules[item.key] = item;
    }
    _updateLocalLastUpdated(remoteTime);
  }

  /// Clears all locally stored modules.
  Future<void> clearLocalModules() async {
    _modules.clear();
    await _storedModules.clear();
    _updateLocalLastUpdated();
    notifyListeners();
  }

  /// Forces uploading the current local modules to the cloud.
  Future<void> forceUploadToCloud() async {
    if (_cloudProvider != null) {
      await _cloudProvider!.syncModules(
        _modules.values.map((e) => (e as MarkItem).toMap()).toList(),
      );
    }
  }

  /// Forces fetching modules from the cloud and overwriting local data.
  Future<void> forceLoadFromCloud() async {
    if (_cloudProvider != null) {
      final data = await _cloudProvider!.fetchAllModules(force: true);
      if (data != null) {
        await _loadFromRemote(data, _cloudProvider!.lastUpdated);
        notifyListeners();
      }
    }
  }

  Future<void> syncOnCloudEnabled(BuildContext context) async {
    if (_cloudProvider == null) return;

    final remoteTs = await _cloudProvider!.fetchRemoteLastUpdated();
    if (_modules.isEmpty) {
      if (remoteTs != null) {
        final data = await _cloudProvider!.fetchAllModules(force: true);
        if (data != null) {
          await _loadFromRemote(data, remoteTs);
          notifyListeners();
        }
      }
      return;
    }

    final localTs = localLastUpdated;
    if (remoteTs != null && (localTs == null || remoteTs.isAfter(localTs))) {
      final useCloud = await _showChoiceDialog(context);
      if (useCloud == true) {
        final data = await _cloudProvider!.fetchAllModules(force: true);
        if (data != null) {
          await _loadFromRemote(data, remoteTs);
          notifyListeners();
        }
      } else if (useCloud == false) {
        await forceUploadToCloud();
      }
    } else {
      await forceUploadToCloud();
    }
  }

  Future<bool?> _showChoiceDialog(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Sync Conflict'),
          content: const Text(
            'Cloud data differs from local data. Which version do you want to keep?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Local'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cloud'),
            ),
          ],
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sync Conflict'),
        content: const Text(
          'Cloud data differs from local data. Which version do you want to keep?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Local'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cloud'),
          ),
        ],
      ),
    );
  }

  /// Returns the current local modules as a list of plain maps. Useful for
  /// debugging and verifying sync operations.
  List<Map<String, dynamic>> exportLocalModules() {
    return _modules.values
        .map((e) => (e as MarkItem).toMap())
        .toList(growable: false);
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
    _sync();
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
    _sync();
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
      contributors: (contributors != null)
          ? contributors
          : HiveList(_storedModules),
      autoWeight: true,
      parent: null,
      weight: 0,
      credits: credits,
    );

    _storedModules.add(m);

    m.save();

    _modules.putIfAbsent(m.key, () => m);

    notifyListeners();
    _sync();
  }

  void removeContributor({
    required MarkItem parent,
    required MarkItem contributor,
  }) {
    _storedModules.delete(contributor.key);

    calculateWeights(parent);

    notifyListeners();
    _sync();
  }

  void removeModule({required int key}) {
    _modules.remove(key);

    notifyListeners();

    _storedModules.delete(key);
    _sync();
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
    _sync();
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
    _sync();
  }

  void reorderContributors({
    required MarkItem parent,
    required int oldIndex,
    required int newIndex,
  }) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = parent.contributors.removeAt(oldIndex) as MarkItem;
    parent.contributors.insert(newIndex, item);
    parent.save();
    notifyListeners();
    _sync();
  }
}
