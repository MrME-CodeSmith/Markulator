import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:markulator/data/repositories/module_repository.dart';
import 'package:markulator/models/module_model.dart';
import 'package:markulator/main.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    Hive.registerAdapter(MarkItemAdapter());
    await Hive.openBox(userModulesBox);
    await Hive.openBox(syncInfoBox);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('module addition updates averages', () {
    final repo = ModuleRepository();

    repo.addModule(name: 'A', mark: 80, contributors: null, credits: 5);
    repo.addModule(name: 'B', mark: 60, contributors: null, credits: 10);

    expect(repo.modules.length, 2);

    expect(repo.averageModulesMark, closeTo(0.7, 0.0001));
    final expectedWeighted = ((0.8 * 5) + (0.6 * 10)) / 15;
    expect(repo.weightedAverageModulesMark, closeTo(expectedWeighted, 0.0001));

    final firstKey = repo.modules.keys.first;
    expect(repo.averageMark(firstKey), closeTo(0.8, 0.0001));
    expect(repo.localLastUpdated, isNotNull);
  });
}
