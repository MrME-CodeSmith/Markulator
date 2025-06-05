import 'package:flutter/material.dart';
import 'package:markulator/Model/boolean_wrapper_model.dart';

import './percentage_input_widget.dart';

class WeightPercentageInputWidget extends StatefulWidget {
  const WeightPercentageInputWidget({
    super.key,
    required this.percentageController,
    required this.val,
  });

  final Boolean val;
  final TextEditingController percentageController;

  @override
  State<WeightPercentageInputWidget> createState() =>
      _WeightPercentageInputWidgetState();
}

class _WeightPercentageInputWidgetState
    extends State<WeightPercentageInputWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return Row(
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.4,
              child: PercentageInputWidget(
                label: "Weight",
                readOnly: widget.val.wrappedValue,
                percentageController: widget.percentageController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 21),
              child: Checkbox(
                value: widget.val.wrappedValue,
                onChanged: (_) {
                  setState(() {
                    widget.val.value = !widget.val.wrappedValue;
                  });
                },
              ),
            ),
            const Text("Auto determine"),
          ],
        );
      }),
    );
  }
}
