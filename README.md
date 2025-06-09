# Markulator

Markulator is a mark tracking application built with Flutter. It lets you
record modules and their contributors, calculates weighted averages and can
sync your data with Firebase. The code follows the **MVVM**
(Model&ndash;View&ndash;ViewModel) pattern: views obtain data from view models
while repositories and services handle persistence and network access.

[![Codemagic build status](https://api.codemagic.io/apps/68447451fe351b264e203d3f/68447451fe351b264e203d3e/status_badge.svg)](https://codemagic.io/app/68447451fe351b264e203d3f/68447451fe351b264e203d3e/latest_build)
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Features
- Track credits for each module
- Weighted average calculation with credits displayed in a carousel on the overview screen
- Optional Google sign-in to sync modules with Firestore
- Automatically pulls newer module data from Firestore when available
- Manage multiple degrees with their own academic years
- Add years to a degree and assign modules to each year
- Degree and year statistics are displayed using carousel widgets

```dart
// Launch the overview listing all degrees with summary statistics
MaterialApp(home: const DegreeOverviewScreen());

// Example statistics carousel for a single year
StatisticsCarousel(
  height: 150,
  items: [
    StatisticItem(
      heading: 'Year average',
      value: repo.averageForYear(yearId),
      isPercentage: true,
    ),
    StatisticItem(
      heading: 'Weighted average',
      value: repo.weightedAverageForYear(yearId),
      isPercentage: true,
    ),
    StatisticItem(
      heading: 'Credits',
      value: repo.creditsForYear(yearId),
    ),
  ],
);
```

## Folder Overview

- **lib/data** &ndash; repositories and services for persistence and Firebase.
- **lib/view_models** &ndash; state classes consumed by the UI.
- **lib/views** &ndash; widgets that present the interface.
- **lib/models** &ndash; plain data objects stored via Hive.
- **lib/domain** &ndash; optional business logic such as use cases.

## Example

```dart
// View
final vm = Provider.of<OverviewViewModel>(context);
vm.initialize(context);

// ViewModel
class OverviewViewModel with ChangeNotifier {
  final ModuleRepository moduleRepository;
  Map<int, MarkItem> get modules => moduleRepository.modules;
}

// Repository
Future<void> setModuleService(ModuleService service) async {
  _service = service;
  final data = await service.fetchModulesIfNewer();
  // ...
}
```

## Testing

Make sure Flutter is installed and that Firebase has been configured with
`flutterfire configure` (this generates `firebase_options.dart`). Then run:

```bash
flutter test
```
