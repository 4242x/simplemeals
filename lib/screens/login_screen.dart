import 'package:flutter/material.dart';
import 'package:simplemeals/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 255, 203),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
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
                              'Student - Log In',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _labeledInput(label: 'User ID'),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Password', obscureText: true),
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

    final signInButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.black87,
          backgroundColor: const Color(0xFF66BB6A),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        onPressed: () {},
        child: const Text('Sign In!', style: TextStyle(fontSize: 16)),
      ),
    );

    final signUpButton = Expanded(
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        },
        child: const Text('Sign Up?', style: TextStyle(fontSize: 16)),
      ),
    );

    if (isNarrow) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: signInButton.child),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: signUpButton.child),
        ],
      );
    }

    return Row(
      children: [signInButton, const SizedBox(width: 20), signUpButton],
    );
  }
}