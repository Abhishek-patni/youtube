import 'package:flutter/material.dart';
import 'package:youtube/Youtube/constant/color_code.dart';

ThemeData theme=ThemeData(
  inputDecorationTheme:  InputDecorationTheme(
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

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Colour.Rinhobar,
    ),
  );
}
