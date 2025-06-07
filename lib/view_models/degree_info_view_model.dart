import 'package:flutter/foundation.dart';

import '../data/repositories/degree_repository.dart';
import '../models/degree_model.dart';
import '../models/degree_year_model.dart';
import '../models/module_model.dart';

class DegreeInfoViewModel with ChangeNotifier {
  final DegreeRepository repository;
  int? degreeId;

  DegreeInfoViewModel({required this.repository});

  void setDegree(int id) {
    if (degreeId != id) {
      degreeId = id;
      notifyListeners();
    }
  }

  Degree? get degree =>
      (degreeId != null) ? repository.degrees[degreeId] : null;

  List<DegreeYear> get years =>
      degree?.years.cast<DegreeYear>().toList(growable: false) ?? const [];

  List<MarkItem> modulesForYear(int yearId) {
    final year = degree?.years.cast<DegreeYear?>().firstWhere(
      (y) => y?.key == yearId,
      orElse: () => null,
    );
    return year?.modules.cast<MarkItem>().toList(growable: false) ?? const [];
  }

  double averageForYear(int yearId) => repository.averageForYear(yearId);

  double weightedAverageForYear(int yearId) =>
      repository.weightedAverageForYear(yearId);

  double creditsForYear(int yearId) => repository.creditsForYear(yearId);

  double get averageForDegree =>
      (degreeId != null) ? repository.averageForDegree(degreeId!) : 0;

  double get weightedAverageForDegree =>
      (degreeId != null) ? repository.weightedAverageForDegree(degreeId!) : 0;

  double get creditsForDegree =>
      (degreeId != null) ? repository.creditsForDegree(degreeId!) : 0;
}
