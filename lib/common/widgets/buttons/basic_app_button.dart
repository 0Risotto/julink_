import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final double? height;
  const BasicAppButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        minimumSize: Size.fromHeight(height ?? 80),
      ),
      child: Text(title, style: TextStyle(color: Colors.white)),
    );
  }
}
