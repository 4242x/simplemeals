
import 'package:flutter/material.dart';
import 'package:simplemeals/screens/institution/institution_dashboard.dart';
import 'package:simplemeals/screens/institution/login_screen.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 208, 255, 203),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
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
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF90E969),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Institution - Sign Up',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _labeledInput(label: 'Create an Institution ID'),
                          const SizedBox(height: 20),
                          _labeledInput(
                              label: 'Create a password', obscureText: true),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Institution Name'),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Current No. of Students'),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'No. of students prefferring Veg'),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'No. of students prefferring Non-Veg'),
                          const SizedBox(height: 30),
                          _actionButtons(context, constraints.maxWidth),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _labeledInput({required String label, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context, double screenWidth) {
    bool isNarrow = screenWidth < 360;

    final signUpButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: const Color(0xFF66BB6A),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        onPressed: () {
                    Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InstitutionDashboard()),
          );
        },
        child: const Text('Sign Up!', style: TextStyle(fontSize: 16)),
      ),
    );

    final logInButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InstitutionLoginScreen()),
          );
        },
        child: const Text('Log In?', style: TextStyle(fontSize: 16)),
      ),
    );

    if (isNarrow) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: signUpButton.child),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: logInButton.child),
        ],
      );
    }

    return Row(
      children: [signUpButton, const SizedBox(width: 20), logInButton],
    );
  }
}