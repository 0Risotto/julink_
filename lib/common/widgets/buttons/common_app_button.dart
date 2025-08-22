import 'package:flutter/material.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/core/configs/theme/app_colors.dart';

class CommonButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? height;
  final double? width; // Add this property for custom width
  final String title;
  CommonButton({
    super.key,
    required this.onPressed,
    this.height,
    this.width, // Custom width parameter
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: context.isDarkMode
            ? const Color.fromARGB(181, 37, 41, 46)
            : AppColors.lightCancelButton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(width ?? 100, height ?? 40), // Set width and height
      ),
      child: Text(
        title,
        style: TextStyle(
          color: context.isDarkMode ? Colors.white54 : Colors.black26,
        ),
      ),
    );
  }
}
