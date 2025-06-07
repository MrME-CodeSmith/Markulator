import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:markulator/view_models/degree_overview_view_model.dart';
import 'package:markulator/data/repositories/degree_repository.dart';
import 'package:markulator/models/degree_model.dart';

class MockDegreeRepository extends Mock implements DegreeRepository {}
class MockDegree extends Mock implements Degree {}

void main() {
  late MockDegreeRepository repo;
  late DegreeOverviewViewModel viewModel;

  setUp(() {
    repo = MockDegreeRepository();
    viewModel = DegreeOverviewViewModel(repository: repo);
  });

  test('exposes degrees from repository', () {
    final deg = MockDegree();
    when(() => repo.degrees).thenReturn({1: deg});
    expect(viewModel.degrees, {1: deg});
  });

  test('averageForDegree delegates to repository', () {
    when(() => repo.averageForDegree(5)).thenReturn(0.6);
    expect(viewModel.averageForDegree(5), 0.6);
    verify(() => repo.averageForDegree(5)).called(1);
  });

  test('weightedAverageForDegree delegates to repository', () {
    when(() => repo.weightedAverageForDegree(5)).thenReturn(0.7);
    expect(viewModel.weightedAverageForDegree(5), 0.7);
    verify(() => repo.weightedAverageForDegree(5)).called(1);
  });
}
