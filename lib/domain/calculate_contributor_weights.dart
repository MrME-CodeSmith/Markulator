import 'dart:math';

import '../Model/module_model.dart';

/// Helper use-case to recalculate contributor weights for a [MarkItem].
///
/// The call operator recalculates the weights for the provided [parent]
/// based on its contributors and updates marks accordingly. Changes are
/// persisted via Hive's [save] method and the calculation is propagated up
/// the hierarchy if the item has a parent.
class CalculateContributorWeights {
  const CalculateContributorWeights();

  void call(MarkItem parent) {
    final List<MarkItem> weightedList = [];
    final List<MarkItem> unweightedList = [];

    for (var i = 0; i < parent.contributors.length; i++) {
      final MarkItem currentContributor = parent.contributors[i] as MarkItem;
      if (!currentContributor.autoWeight) {
        weightedList.add(currentContributor);
      } else {
        unweightedList.add(currentContributor);
      }
    }

    parent.mark = 0;
    double totalWeight = 0;
    for (final c in weightedList) {
      totalWeight += (c.weight * 100);
      parent.mark += (c.mark * 100) * c.weight;
    }

    final double remainingWeight = unweightedList.isNotEmpty
        ? (100 - totalWeight) / unweightedList.length
        : 0;

    for (final c in unweightedList) {
      c.weight = max((remainingWeight / 100), 0);
      c.save();
      parent.mark += (c.mark * 100) * c.weight;
    }

    parent.mark /= 100;
    parent.save();

    if (parent.parent != null) {
      call(parent.parent!);
    }
  }
}
