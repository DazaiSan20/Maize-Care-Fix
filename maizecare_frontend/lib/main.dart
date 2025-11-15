import 'package:flutter/material.dart';
import 'presentation/screens/auth/splash_screen.dart';

void main() {
  runApp(const MaizeCareApp());
}

class MaizeCareApp extends StatelessWidget {
  const MaizeCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaizeCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}