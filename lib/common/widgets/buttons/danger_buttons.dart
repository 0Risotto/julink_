import 'package:flutter/material.dart';

class DangerButton extends StatelessWidget {
  final VoidCallback onPressed; // ← make nullable
  final String title;
  final double? height;

  const DangerButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // can be null (disabled)
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled))
            return Colors.red.shade200;
          if (states.contains(MaterialState.pressed))
            return Colors.red.shade700;
          return Colors.red;
        }),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        minimumSize: MaterialStateProperty.all(Size.fromHeight(height ?? 80)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      child: Text(title),
    );
  }
}
