import 'cloud_service.dart';

class ModuleService {
  final CloudService cloudService;

  ModuleService({required this.cloudService});

  Future<void> syncModules(List<Map<String, dynamic>> modules) async {
    await cloudService.syncModules(modules);
  }

  Future<List<Map<String, dynamic>>?> fetchModulesIfNewer() async {
    return cloudService.fetchModulesIfNewer();
  }

  Future<List<Map<String, dynamic>>?> fetchAllModules({bool force = false}) {
    return cloudService.fetchAllModules(force: force);
  }

  Future<DateTime?> fetchRemoteLastUpdated() {
    return cloudService.fetchRemoteLastUpdated();
  }
}
