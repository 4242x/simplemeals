import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simplemeals/screens/provider/login_screen.dart';
import 'package:simplemeals/screens/provider/provider_dashboard.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final TextEditingController providerIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  bool isLoading = false;

  Future<void> _signUp() async {
    final providerId = providerIdController.text.trim();
    final password = passwordController.text.trim();
    final state = stateController.text.trim();
    final city = cityController.text.trim();

    if (providerId.isEmpty || password.isEmpty || state.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check if Provider ID already exists
      final existing = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .get();

      if (existing.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Provider ID already exists")),
        );
      } else {
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(providerId)
            .set({
          'providerId': providerId,
          'password': password,
          'state': state,
          'city': city,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProviderDashboard()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
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
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Provider - Sign Up',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _labeledInput(
                            label: 'Create a Provider ID',
                            controller: providerIdController,
                          ),
                          const SizedBox(height: 20),
                          _labeledInput(
                            label: 'Create a password',
                            obscureText: true,
                            controller: passwordController,
                          ),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Select State', controller: stateController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Enter City', controller: cityController),
                          const SizedBox(height: 20),
                          _actionButtons(context, constraints.maxWidth),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
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

  Widget _labeledInput({
    required String label,
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF66BB6A),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        onPressed: _signUp,
        child: const Text('Sign Up!', style: TextStyle(fontSize: 16)),
      ),
    );

    final logInButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProviderLoginScreen()),
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
