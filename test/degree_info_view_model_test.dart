import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:markulator/view_models/degree_info_view_model.dart';
import 'package:markulator/data/repositories/degree_repository.dart';
import 'package:markulator/models/degree_model.dart';

class MockDegreeRepository extends Mock implements DegreeRepository {}
class MockDegree extends Mock implements Degree {}

void main() {
  late MockDegreeRepository repo;
  late DegreeInfoViewModel viewModel;

  setUp(() {
    repo = MockDegreeRepository();
    viewModel = DegreeInfoViewModel(repository: repo);
  });

  test('degree is retrieved from repository using setDegree', () {
    final deg = MockDegree();
    when(() => repo.degrees).thenReturn({10: deg});
    viewModel.setDegree(10);
    expect(viewModel.degree, deg);
  });

  test('average and weighted averages delegate to repository', () {
    viewModel.setDegree(2);
    when(() => repo.averageForYear(1)).thenReturn(0.5);
    when(() => repo.weightedAverageForYear(1)).thenReturn(0.6);
    when(() => repo.averageForDegree(2)).thenReturn(0.7);
    when(() => repo.weightedAverageForDegree(2)).thenReturn(0.8);

    expect(viewModel.averageForYear(1), 0.5);
    expect(viewModel.weightedAverageForYear(1), 0.6);
    expect(viewModel.averageForDegree, 0.7);
    expect(viewModel.weightedAverageForDegree, 0.8);

    verify(() => repo.averageForYear(1)).called(1);
    verify(() => repo.weightedAverageForYear(1)).called(1);
    verify(() => repo.averageForDegree(2)).called(1);
    verify(() => repo.weightedAverageForDegree(2)).called(1);
  });
}
