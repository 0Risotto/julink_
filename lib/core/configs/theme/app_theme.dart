import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Light Theme
  static final lightTheme = ThemeData(
    primaryColor: AppColors.lightPrimaryButton,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightInputText,
      selectionColor: AppColors.lightInputText.withOpacity(0.4),
      selectionHandleColor: AppColors.lightInputText,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputFieldBackground,
      hintStyle: TextStyle(color: AppColors.lightPlaceholderText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimaryButton,
        foregroundColor: AppColors.lightButtonText,
        textStyle: TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.lightLinkText),
    ),
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    primaryColor: AppColors.darkPrimaryButton,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkInputText,
      selectionColor: AppColors.darkInputText.withOpacity(0.4),
      selectionHandleColor: AppColors.darkInputText,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFieldBackground,
      hintStyle: TextStyle(color: AppColors.darkPlaceholderText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimaryButton,
        foregroundColor: AppColors.darkButtonText,
        textStyle: TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.darkLinkText),
    ),
  );
}
