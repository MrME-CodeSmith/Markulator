import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../main.dart';
import '../../models/degree_model.dart';
import '../../models/degree_year_model.dart';
import '../../models/module_model.dart';
import 'module_repository.dart';
import '../services/module_service.dart';

/// Repository managing [Degree] and [DegreeYear] persistence.
class DegreeRepository with ChangeNotifier {
  final ModuleRepository moduleRepository;
  late final Box _degreeBox;
  late final Box _yearBox;
  late final Box _syncBox;
  ModuleService? _service;
  final Map<dynamic, Degree> _degrees = {};

  DegreeRepository({required this.moduleRepository}) {
    _degreeBox = Hive.box(degreesBox);
    _yearBox = Hive.box(degreeYearsBox);
    _syncBox = Hive.box(syncInfoBox);
    _degrees.addAll(_degreeBox.toMap().cast<dynamic, Degree>());
  }

  DateTime? get localLastUpdated =>
      _syncBox.get('degreeLocalLastUpdated') as DateTime?;

  void _updateLocalLastUpdated([DateTime? time]) {
    _syncBox.put('degreeLocalLastUpdated', time ?? DateTime.now());
  }

  /// Map of stored degrees keyed by Hive id.
  Map<dynamic, Degree> get degrees => {..._degrees};

  /// Create a new degree and return its Hive key.
  int addDegree(String name) {
    final degree = Degree(name: name, years: HiveList(_yearBox));
    _degreeBox.add(degree);
    degree.save();
    _degrees[degree.key] = degree;
    notifyListeners();
    _sync();
    return degree.key as int;
  }

  /// Remove a degree and all of its years and modules.
  void removeDegree(int degreeId) {
    final degree = _degrees[degreeId];
    if (degree == null) return;
    for (final year in List<DegreeYear>.from(degree.years)) {
      removeYear(degreeId, year.key as int);
    }
    _degrees.remove(degreeId);
    _degreeBox.delete(degreeId);
    notifyListeners();
    _sync();
  }

  /// Add a year to the given degree and return its Hive key.
  int addYear(int degreeId, {int? yearIndex}) {
    final degree = _degrees[degreeId];
    if (degree == null) throw ArgumentError('Degree not found');
    final index = yearIndex ?? degree.years.length + 1;
    final year = DegreeYear(
      yearIndex: index,
      modules: HiveList(Hive.box(userModulesBox)),
    );
    _yearBox.add(year);
    year.save();
    degree.years.add(year);
    degree.save();
    notifyListeners();
    _sync();
    return year.key as int;
  }

  /// Remove the specified year and all of its modules.
  void removeYear(int degreeId, int yearId) {
    final degree = _degrees[degreeId];
    if (degree == null) return;
    final year = degree.years.cast<DegreeYear?>().firstWhere(
          (y) => y?.key == yearId,
          orElse: () => null,
        );
    if (year == null) return;

    // remove modules belonging to year
    for (final m in List<MarkItem>.from(year.modules)) {
      moduleRepository.removeModule(key: m.key as int);
    }

    degree.years.remove(year);
    degree.save();
    _yearBox.delete(yearId);
    notifyListeners();
    _sync();
  }

  /// Add a module to a year within the given degree.
  void addModule(
    int degreeId,
    int yearId, {
    required String name,
    required double mark,
    required double credits,
    HiveList? contributors,
  }) {
    final degree = _degrees[degreeId];
    if (degree == null) throw ArgumentError('Degree not found');
    final year = degree.years.cast<DegreeYear?>().firstWhere(
          (y) => y?.key == yearId,
          orElse: () => null,
        );
    if (year == null) throw ArgumentError('Year not found');
    moduleRepository.addModule(
      name: name,
      mark: mark,
      contributors: contributors,
      credits: credits,
      year: year,
    );
    notifyListeners();
    _sync();
  }

  /// Average mark of all modules in a year.
  double averageForYear(int yearId) {
    final year = _yearBox.get(yearId);
    if (year == null) return 0;
    if (year.modules.isEmpty) return 0;
    double total = 0;
    for (final m in year.modules.cast<MarkItem>()) {
      total += m.mark;
    }
    return total / year.modules.length;
  }

  /// Weighted average mark of a year based on credits.
  double weightedAverageForYear(int yearId) {
    final year = _yearBox.get(yearId);
    if (year == null) return 0;
    double weightedTotal = 0;
    double creditTotal = 0;
    for (final m in year.modules.cast<MarkItem>()) {
      weightedTotal += m.mark * m.credits;
      creditTotal += m.credits;
    }
    return creditTotal > 0 ? weightedTotal / creditTotal : 0;
  }

  /// Average mark across all years of a degree.
  double averageForDegree(int degreeId) {
    final degree = _degrees[degreeId];
    if (degree == null) return 0;
    final modules = degree.years
        .expand((y) => y.modules.cast<MarkItem>())
        .toList(growable: false);
    if (modules.isEmpty) return 0;
    final total = modules.fold<double>(0, (prev, m) => prev + m.mark);
    return total / modules.length;
  }

  /// Weighted average across all years of a degree.
  double weightedAverageForDegree(int degreeId) {
    final degree = _degrees[degreeId];
    if (degree == null) return 0;
    double weighted = 0;
    double credits = 0;
    for (final m in degree.years.expand((y) => y.modules.cast<MarkItem>())) {
      weighted += m.mark * m.credits;
      credits += m.credits;
    }
    return credits > 0 ? weighted / credits : 0;
  }

  Future<void> setModuleService(ModuleService service) async {
    _service = service;
    final data = await service.fetchDegreesIfNewer();
    if (data != null) {
      await _loadFromRemote(data, service.cloudService.lastUpdated);
      notifyListeners();
    }
  }

  void _sync() {
    _updateLocalLastUpdated();
    if (_service != null) {
      _service!.syncDegrees(
        _degrees.values.map((d) => d.toMap()).toList(),
      );
    }
  }

  Future<void> _loadFromRemote(
    List<Map<String, dynamic>> data, [
    DateTime? remoteTime,
  ]) async {
    await moduleRepository.clearLocalModules();
    _degrees.clear();
    await _degreeBox.clear();
    await _yearBox.clear();
    final modulesBox = Hive.box(userModulesBox);
    for (final degMap in data) {
      final deg = Degree.fromMap(
        Map<String, dynamic>.from(degMap),
        _degreeBox,
        _yearBox,
        modulesBox,
      );
      _degrees[deg.key] = deg;
    }
    _updateLocalLastUpdated(remoteTime);
  }
}
