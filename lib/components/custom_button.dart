import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String todoText;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.todoText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.brown[500],
      child: Text(todoText),
    );
  }
}