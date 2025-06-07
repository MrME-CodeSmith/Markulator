import 'package:flutter/foundation.dart';

import '../data/repositories/degree_repository.dart';
import '../models/degree_model.dart';

class DegreeOverviewViewModel with ChangeNotifier {
  final DegreeRepository repository;

  DegreeOverviewViewModel({required this.repository});

  Map<dynamic, Degree> get degrees => repository.degrees;

  double averageForDegree(int degreeId) =>
      repository.averageForDegree(degreeId);

  double weightedAverageForDegree(int degreeId) =>
      repository.weightedAverageForDegree(degreeId);

  double creditsForDegree(int degreeId) =>
      repository.creditsForDegree(degreeId);
}
