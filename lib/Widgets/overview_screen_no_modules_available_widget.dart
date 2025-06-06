import 'package:flutter/material.dart';

class OverviewScreenNoModulesAvailable extends StatelessWidget {
  const OverviewScreenNoModulesAvailable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
              Text(
                "No modules available\nTry adding some.",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
