import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme{
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 3)
      );
  static final darkThemeMode =  ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(24),
      focusedBorder: _border(Pallete.gradient2),
      enabledBorder: _border(Pallete.borderColor)
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Pallete.backgroundColor
    )
  );
}