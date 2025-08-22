import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  /// Updates the current theme mode
  void updateTheme(ThemeMode themeMode) => emit(themeMode);

  /// Deserialize the theme mode from stored JSON
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final theme = json['theme'] as String?;
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Serialize the theme mode into JSON
  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    late final String theme;
    switch (state) {
      case ThemeMode.light:
        theme = 'light';
        break;
      case ThemeMode.dark:
        theme = 'dark';
        break;
      case ThemeMode.system:
        theme = 'system';
        break;
    }
    return {'theme': theme};
  }
}
