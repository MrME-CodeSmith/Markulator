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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'years': years.map((y) => (y as DegreeYear).toMap()).toList(),
    };
  }

  static Degree fromMap(
    Map<String, dynamic> map,
    Box degreeBox,
    Box yearBox,
    Box moduleBox,
  ) {
    final degree = Degree(
      name: map['name'] as String,
      years: HiveList(yearBox),
    );
    degreeBox.add(degree);
    if (map['years'] != null) {
      for (final y in (map['years'] as List)) {
        degree.years.add(
          DegreeYear.fromMap(Map<String, dynamic>.from(y), yearBox, moduleBox),
        );
      }
    }
    degree.save();
    return degree;
  }
}
