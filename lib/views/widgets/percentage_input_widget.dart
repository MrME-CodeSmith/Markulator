import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PercentageInputWidget extends StatelessWidget {
  const PercentageInputWidget({
    super.key,
    required this.label,
    required this.readOnly,
    required this.percentageController,
  });

  final bool readOnly;
  final String label;
  final TextEditingController percentageController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return TextField(
          readOnly: readOnly,
          controller: percentageController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            TextInputFormatter.withFunction(
              (oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.replaceAll(',', '.')),
            ),
          ],
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: label,
            suffixIcon: const Icon(Icons.percent),
            contentPadding: const EdgeInsets.only(left: 7),
            hintText: "0.00",
          ),
        );
      },
    );
  }
}
