import 'package:flutter/material.dart';
import 'colors.dart';

abstract final class AppTheme {
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColor.seedColor,
    brightness: Brightness.light,
  );

  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightColorScheme,
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: _lightColorScheme.surface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      selectedItemColor: _lightColorScheme.primary,
      unselectedItemColor: _lightColorScheme.onSurfaceVariant,
      elevation: 8,
    ),
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColor.seedColor,
    brightness: Brightness.dark,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: _darkColorScheme,
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: _darkColorScheme.surface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkColorScheme.surface,
      selectedItemColor: _darkColorScheme.primary,
      unselectedItemColor: _darkColorScheme.onSurfaceVariant,
      elevation: 8,
    ),
  );
}
