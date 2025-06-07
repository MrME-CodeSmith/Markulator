import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/module_model.dart';
import '../../models/degree_year_model.dart';
import '../../main.dart';
import '../services/module_service.dart';
import '../../domain/calculate_contributor_weights.dart';

class ModuleRepository with ChangeNotifier {
  late final dynamic _storedModules;
  late final Map<dynamic, dynamic> _modules;
  late final Box _syncBox;
  ModuleService? _service;
  final CalculateContributorWeights _calculateContributorWeights;

  ModuleRepository({CalculateContributorWeights? calculateContributorWeights})
    : _calculateContributorWeights =
          calculateContributorWeights ?? const CalculateContributorWeights() {
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

  Future<void> setModuleService(ModuleService service) async {
    _service = service;
    final data = await service.fetchModulesIfNewer();
    if (data != null) {
      await _loadFromRemote(data, service.cloudService.lastUpdated);
      notifyListeners();
    }
  }

  void _sync() {
    _updateLocalLastUpdated();
    if (_service != null) {
      _service!.syncModules(
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

  Future<void> clearLocalModules() async {
    _modules.clear();
    await _storedModules.clear();
    _updateLocalLastUpdated();
    notifyListeners();
  }

  Future<void> forceUploadToCloud() async {
    if (_service != null) {
      await _service!.syncModules(
        _modules.values.map((e) => (e as MarkItem).toMap()).toList(),
      );
    }
  }

  Future<void> forceLoadFromCloud() async {
    if (_service != null) {
      final data = await _service!.fetchAllModules(force: true);
      if (data != null) {
        await _loadFromRemote(data, _service!.cloudService.lastUpdated);
        notifyListeners();
      }
    }
  }

  Future<void> syncOnCloudEnabled(BuildContext context) async {
    if (_service == null) return;
    final remoteTs = await _service!.fetchRemoteLastUpdated();
    if (_modules.isEmpty) {
      if (remoteTs != null) {
        final data = await _service!.fetchAllModules(force: true);
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
        final data = await _service!.fetchAllModules(force: true);
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
    _calculateContributorWeights(parent);
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
    _calculateContributorWeights(parent);
    notifyListeners();
    parent.contributors[index].save();
    _sync();
  }

  void addModule({
    required String name,
    required double mark,
    required HiveList? contributors,
    required double credits,
    DegreeYear? year,
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
    if (year != null) {
      year.modules.add(m);
      year.save();
    }
    notifyListeners();
    _sync();
  }

  void removeContributor({
    required MarkItem parent,
    required MarkItem contributor,
  }) {
    _storedModules.delete(contributor.key);
    _calculateContributorWeights(parent);
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
