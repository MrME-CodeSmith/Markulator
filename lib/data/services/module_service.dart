import 'cloud_service.dart';

class ModuleService {
  final CloudService cloudService;

  ModuleService({required this.cloudService});

  Future<void> syncModules(List<Map<String, dynamic>> modules) async {
    await cloudService.syncModules(modules);
  }

  Future<void> syncDegrees(List<Map<String, dynamic>> degrees) async {
    await cloudService.syncDegrees(degrees);
  }

  Future<List<Map<String, dynamic>>?> fetchModulesIfNewer() async {
    return cloudService.fetchModulesIfNewer();
  }

  Future<List<Map<String, dynamic>>?> fetchDegreesIfNewer() async {
    return cloudService.fetchDegreesIfNewer();
  }

  Future<List<Map<String, dynamic>>?> fetchAllModules({bool force = false}) {
    return cloudService.fetchAllModules(force: force);
  }

  Future<List<Map<String, dynamic>>?> fetchAllDegrees({bool force = false}) {
    return cloudService.fetchAllDegrees(force: force);
  }

  Future<DateTime?> fetchRemoteLastUpdated() {
    return cloudService.fetchRemoteLastUpdated();
  }

  Future<DateTime?> fetchDegreeRemoteLastUpdated() {
    return cloudService.fetchDegreeRemoteLastUpdated();
  }
}
