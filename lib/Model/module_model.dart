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

  @HiveField(8)
  double credits;

  MarkItem({
    required this.name,
    required this.mark,
    required this.contributors,
    required this.weight,
    required this.parent,
    required this.autoWeight,
    required this.credits,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mark': mark,
      'weight': weight,
      'autoWeight': autoWeight,
      'credits': credits,
      'contributors': contributors.map((c) => (c as MarkItem).toMap()).toList(),
    };
  }

  static MarkItem fromMap(Map<String, dynamic> map, Box box,
      [MarkItem? parent]) {
    final item = MarkItem(
      name: map['name'] as String,
      mark: (map['mark'] as num).toDouble(),
      contributors: HiveList(box),
      weight: (map['weight'] as num).toDouble(),
      parent: parent,
      autoWeight: map['autoWeight'] as bool,
      credits: (map['credits'] as num).toDouble(),
    );
    box.add(item);
    if (map['contributors'] != null) {
      for (final c in (map['contributors'] as List)) {
        item.contributors.add(fromMap(Map<String, dynamic>.from(c), box, item));
      }
    }
    item.save();
    return item;
  }
}
