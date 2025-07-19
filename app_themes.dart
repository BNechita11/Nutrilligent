import 'package:flutter/material.dart';

enum AppTheme { purple, dark }

final appThemeData = {
  AppTheme.purple: ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color.fromARGB(255, 33, 3, 44),
  ),

  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Color(0xFF121212),
  ),
};
