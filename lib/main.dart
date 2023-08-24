import 'package:flutter/material.dart';
import 'package:youtube/Youtube/functions/dark_light.dart';
import 'package:youtube/splash/splash_screen.dart';
import 'dart:ui_web';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: "Youtube video Downloader",
        home: const Splash_Screen(),
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system, // Automatically use light or dark mode based on system settings
      ),
    );
  }
}
