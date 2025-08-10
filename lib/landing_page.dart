import 'package:flutter/material.dart';
import 'package:simplemeals/screens/institution/login_screen.dart';
import 'package:simplemeals/screens/provider/login_screen.dart';
import 'package:simplemeals/screens/student/login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: Text(
                  'SimpleMeals',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 48,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF90E969),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Account Type -',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildAccountButton(
                      text: 'Student',
                      onTap: () {
                        Navigator.push( // Changed from pushReplacement
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentLoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildAccountButton(
                      text: 'Institution',
                      onTap: () {
                        Navigator.push( // Changed from pushReplacement
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InstitutionLoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildAccountButton(
                      text: 'Provider',
                      isDark: true,
                      onTap: () {
                        Navigator.push( // Changed from pushReplacement
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProviderLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountButton({
    required String text,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : const Color(0xFF66BB6A),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
