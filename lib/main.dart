import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/colors.dart';
import 'utils/text_styles.dart';

void main() {
  runApp(GymTechApp());
}

class GymTechApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'Teko',
      ),
      home: LoginScreen(),
    );
  }
}