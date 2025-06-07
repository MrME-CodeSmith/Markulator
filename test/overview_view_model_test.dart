import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:markulator/view_models/overview_view_model.dart';
import 'package:markulator/data/repositories/module_repository.dart';
import 'package:markulator/data/services/system_information_service.dart';
import 'package:markulator/models/module_model.dart';

class MockModuleRepository extends Mock implements ModuleRepository {}
class MockSystemInfo extends Mock implements SystemInformationService {}
class MockMarkItem extends Mock implements MarkItem {}
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  late MockModuleRepository repo;
  late MockSystemInfo systemInfo;
  late OverviewViewModel viewModel;

  setUp(() {
    repo = MockModuleRepository();
    systemInfo = MockSystemInfo();
    viewModel = OverviewViewModel(
      moduleRepository: repo,
      systemInfoProvider: systemInfo,
    );
  });

  test('initialize forwards call to systemInfo', () {
    final ctx = FakeBuildContext();
    viewModel.initialize(ctx);
    verify(() => systemInfo.initialize(ctx)).called(1);
  });

  test('exposes values from repository', () {
    final item = MockMarkItem();
    when(() => repo.modules).thenReturn({1: item});
    when(() => repo.averageModulesMark).thenReturn(0.5);
    when(() => repo.weightedAverageModulesMark).thenReturn(0.6);

    expect(viewModel.modules, {1: item});
    expect(viewModel.averageModulesMark, 0.5);
    expect(viewModel.weightedAverageModulesMark, 0.6);
  });

  test('reorderModules delegates to repository', () {
    viewModel.reorderModules(1, 2);
    verify(() => repo.reorderModules(1, 2)).called(1);
  });
}
