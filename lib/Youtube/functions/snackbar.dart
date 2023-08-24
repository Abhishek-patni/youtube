import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:youtube/Youtube/constant/color_code.dart';

AnimatedSnackBar animatedSnackBar(String text) {
  return AnimatedSnackBar(
    mobileSnackBarPosition: MobileSnackBarPosition.bottom,
    builder: ((context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        height: 70,
        child: Text(text,style: TextStyle(color: Colour.ObsedianBlack),),
      );
    }),
  );
}
// const Text('Storage permission permanently denied. Open app settings to grant permission.'),