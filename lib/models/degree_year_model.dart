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

  Map<String, dynamic> toMap() {
    return {
      'yearIndex': yearIndex,
      'modules': modules.map((m) => (m as MarkItem).toMap()).toList(),
    };
  }

  static DegreeYear fromMap(
    Map<String, dynamic> map,
    Box yearBox,
    Box moduleBox,
  ) {
    final year = DegreeYear(
      yearIndex: map['yearIndex'] as int,
      modules: HiveList(moduleBox),
    );
    yearBox.add(year);
    if (map['modules'] != null) {
      for (final m in (map['modules'] as List)) {
        year.modules.add(
          MarkItem.fromMap(Map<String, dynamic>.from(m), moduleBox),
        );
      }
    }
    year.save();
    return year;
  }
}
