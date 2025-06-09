import 'package:flutter/material.dart';

import './percentage_input_widget.dart';

class WeightPercentageInputWidget extends StatefulWidget {
  const WeightPercentageInputWidget({
    super.key,
    required this.percentageController,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final TextEditingController percentageController;
  final ValueChanged<bool> onChanged;

  @override
  State<WeightPercentageInputWidget> createState() =>
      _WeightPercentageInputWidgetState();
}

class _WeightPercentageInputWidgetState
    extends State<WeightPercentageInputWidget> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.value;
  }

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
                readOnly: _checked,
                percentageController: widget.percentageController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 21),
              child: Checkbox(
                value: _checked,
                onChanged: (_) {
                  setState(() {
                    _checked = !_checked;
                    widget.onChanged(_checked);
                  });
                },
              ),
            ),
            Text(
              "Auto determine",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      }),
    );
  }
}
