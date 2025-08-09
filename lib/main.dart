import 'package:flutter/material.dart';
import 'package:simplemeals/landing_page.dart';
import 'package:simplemeals/screens/institution/institution_dashboard.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SimpleMeals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        fontFamily: 'Poppins',
        useMaterial3: true
      ),
      home: const LandingPage(),
    );
  }
}

