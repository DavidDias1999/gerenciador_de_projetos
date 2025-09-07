import 'package:flutter/material.dart';
import 'colors.dart';

abstract final class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.seedColor,
      brightness: Brightness.light,
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.seedColor,
      brightness: Brightness.dark,
    ),
  );
}
