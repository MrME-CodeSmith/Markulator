import 'package:flutter/material.dart';

class OverviewScreenNoModulesAvailable extends StatelessWidget {
  const OverviewScreenNoModulesAvailable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Text(
          "No modules available\nTry adding some.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
