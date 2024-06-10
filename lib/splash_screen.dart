import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:picnicpalfinal/Login.dart';

// import 'package:untitled1/main.dart';
class splash_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(
        'assets/Logo.png',
        width: 200,
        height: 200,
        fit: BoxFit.fitWidth,
      ),
      nextScreen: Login(), // Make sure HomeScreen is wrapped in a Navigator.
      splashTransition: SplashTransition.fadeTransition,
      duration: 3000,
    );
  }
}
