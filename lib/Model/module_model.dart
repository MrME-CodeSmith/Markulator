import 'package:hive/hive.dart';

import 'package:flutter/material.dart';

part 'module_model.g.dart';

@HiveType(typeId: 0)
class MarkItem extends HiveObject {
  @HiveField(1)
  final String id = UniqueKey().toString();

  @HiveField(2)
  String name;

  @HiveField(3)
  double mark;

  @HiveField(4)
  HiveList contributors;

  @HiveField(5)
  double weight;

  @HiveField(6)
  bool autoWeight;

  @HiveField(7)
  MarkItem? parent;

  MarkItem({
    required this.name,
    required this.mark,
    required this.contributors,
    required this.weight,
    required this.parent,
    required this.autoWeight,
  });
}
