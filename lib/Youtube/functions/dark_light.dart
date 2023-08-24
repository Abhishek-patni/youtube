import 'package:flutter/material.dart';
import 'package:youtube/Youtube/constant/color_code.dart';
import 'package:youtube/Youtube/constant/theme_data.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: Colour.ObsedianBlack,
    border: outlineInputBorder(),
    errorBorder:  const OutlineInputBorder(),
    enabledBorder:  const OutlineInputBorder(),
    focusedBorder:  const OutlineInputBorder(),
    disabledBorder:  const OutlineInputBorder(),
  ),
  scaffoldBackgroundColor: Colour.Backgroud_color,
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    color: Colour.Rinhobar,
  ),
);

final darkTheme = ThemeData(
  // Define your dark theme colors, typography, and other properties here
  brightness: Brightness.dark,
  primaryColor: Colors.deepPurple,
  inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: Colour.Backgroud_color,
    border: const OutlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.solid,
        color: Colors.white, // Set the border color to white
      ),
    ),
    errorBorder:  const OutlineInputBorder(),
    enabledBorder:  const OutlineInputBorder(),
    focusedBorder:  const OutlineInputBorder(),
    disabledBorder:  const OutlineInputBorder(),
  ),
  useMaterial3: true,
  // ... other properties ...
);
OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Colour.Rinhobar,
    ),
  );
}
