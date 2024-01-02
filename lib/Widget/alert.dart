import 'package:flutter/material.dart';

class AlertAction extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback button;

  const AlertAction(
      {Key? key,
      required this.title,
      required this.content,
      required this.button})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade300,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: button,
            child: const Text('Ok')),
      ],
    );
  }
}
