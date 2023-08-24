// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:youtube/Youtube/screens/home.dart';
import 'package:page_transition/page_transition.dart';

class Splash_Screen extends StatelessWidget {
  const Splash_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: "images/icon.png",
      nextScreen: const DownloaderPage(),
      splashTransition: SplashTransition.rotationTransition,
      centered: true,
      duration: 2200, // Adjust duration as needed
      backgroundColor: Colors.white, // Set the background color of the splash screen
      splashIconSize: 200, // Set the size of the splash icon
      pageTransitionType: PageTransitionType.bottomToTop,
      animationDuration: const Duration(milliseconds: 1000),// Provide a default transition type
    );
  }
}