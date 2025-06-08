import 'package:flutter/material.dart';

class DegreeCreationDialog extends StatefulWidget {
  final String title;
  final String confirmText;
  final String? initialName;
  final void Function(String) onSubmit;

  const DegreeCreationDialog({
    super.key,
    required this.title,
    required this.confirmText,
    required this.onSubmit,
    this.initialName,
  });

  @override
  State<DegreeCreationDialog> createState() => _DegreeCreationDialogState();
}

class _DegreeCreationDialogState extends State<DegreeCreationDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: Theme.of(context).textTheme.bodyMedium),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Degree name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              widget.onSubmit(name);
              Navigator.of(context).pop();
            }
          },
          child:
              Text(widget.confirmText, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
