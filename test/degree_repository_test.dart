import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';

import 'package:markulator/data/repositories/module_repository.dart';
import 'package:markulator/data/repositories/degree_repository.dart';
import 'package:markulator/models/module_model.dart';
import 'package:markulator/models/degree_model.dart';
import 'package:markulator/models/degree_year_model.dart';
import 'package:markulator/main.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    Hive.registerAdapter(MarkItemAdapter());
    Hive.registerAdapter(DegreeYearAdapter());
    Hive.registerAdapter(DegreeAdapter());
    await Hive.openBox(userModulesBox);
    await Hive.openBox(degreeYearsBox);
    await Hive.openBox(degreesBox);
    await Hive.openBox(syncInfoBox);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('degree and year management with averages', () {
    final moduleRepo = ModuleRepository();
    final degreeRepo = DegreeRepository(moduleRepository: moduleRepo);

    final degId = degreeRepo.addDegree('CS');
    final yearId = degreeRepo.addYear(degId);

    degreeRepo.addModule(
      degId,
      yearId,
      name: 'A',
      mark: 80,
      credits: 5,
      contributors: null,
    );
    degreeRepo.addModule(
      degId,
      yearId,
      name: 'B',
      mark: 60,
      credits: 10,
      contributors: null,
    );

    expect(degreeRepo.degrees.length, 1);
    expect(moduleRepo.modules.length, 2);

    expect(degreeRepo.averageForYear(yearId), closeTo(0.7, 0.0001));
    final expectedWeighted = ((0.8 * 5) + (0.6 * 10)) / 15;
    expect(
      degreeRepo.weightedAverageForYear(yearId),
      closeTo(expectedWeighted, 0.0001),
    );
    expect(degreeRepo.creditsForYear(yearId), 15);
    expect(degreeRepo.averageForDegree(degId), closeTo(0.7, 0.0001));
    expect(
      degreeRepo.weightedAverageForDegree(degId),
      closeTo(expectedWeighted, 0.0001),
    );
    expect(degreeRepo.creditsForDegree(degId), 15);

    degreeRepo.removeYear(degId, yearId);
    expect(degreeRepo.degrees[degId]!.years.isEmpty, true);
    expect(moduleRepo.modules.isEmpty, true);

    final y2 = degreeRepo.addYear(degId);
    degreeRepo.addModule(
      degId,
      y2,
      name: 'C',
      mark: 90,
      credits: 5,
      contributors: null,
    );
    degreeRepo.removeDegree(degId);
    expect(degreeRepo.degrees.isEmpty, true);
    expect(moduleRepo.modules.isEmpty, true);
  });
}
