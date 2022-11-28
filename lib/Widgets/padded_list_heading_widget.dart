import 'package:flutter/material.dart';

class PaddedListHeadingWidget extends StatelessWidget {
  const PaddedListHeadingWidget({
    Key? key,
    required this.headingName,
  }) : super(key: key);

  final String headingName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 7, 3, 0),
      child: Text(
        headingName,
        style: const TextStyle(fontSize: 22),
        textAlign: TextAlign.left,
      ),
    );
  }
}
