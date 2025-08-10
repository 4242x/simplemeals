import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/screens/institution/institution_dashboard.dart';
import 'package:simplemeals/screens/provider/provider_dashboard.dart';
import 'package:simplemeals/screens/student/student_dashboard.dart';

import 'landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getStartPage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No one is logged in
      return const LandingPage();
    }

    // Fetch role from Firestore
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!snap.exists || !snap.data()!.toString().contains('role')) {
        // No role found → go to landing
        return const LandingPage();
      }

      String role = snap['role'];

      switch (role) {
        case 'provider':
          return const ProviderDashboard();
        case 'institution':
          return const InstitutionDashboard();
        case 'student':
          return const StudentDashboard();
        default:
          return const LandingPage();
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return const LandingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getStartPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const LandingPage();
      },
    );
  }
}
