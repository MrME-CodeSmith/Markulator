import 'package:flutter/material.dart';

class PaddedListHeadingWidget extends StatelessWidget {
  const PaddedListHeadingWidget({
    super.key,
    required this.headingName,
  });

  final String headingName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 7, 3, 0),
      child: Text(
        headingName,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.left,
      ),
    );
  }
}
