import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'degree_year_model.dart';

part 'degree_model.g.dart';

@HiveType(typeId: 2)
class Degree extends HiveObject {
  @HiveField(1)
  final String id = UniqueKey().toString();

  @HiveField(2)
  String name;

  @HiveField(3)
  HiveList<DegreeYear> years;

  Degree({
    required this.name,
    required this.years,
  });
}
