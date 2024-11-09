import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: onCancel,
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('确认'),
        ),
      ],
    );
  }
}
