import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'module_model.dart';

part 'degree_year_model.g.dart';

@HiveType(typeId: 1)
class DegreeYear extends HiveObject {
  @HiveField(1)
  final String id = UniqueKey().toString();

  @HiveField(2)
  int yearIndex;

  @HiveField(3)
  HiveList<MarkItem> modules;

  DegreeYear({
    required this.yearIndex,
    required this.modules,
  });
}
