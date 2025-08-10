import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/screens/institution/login_screen.dart';
import 'package:simplemeals/screens/institution/institution_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _vegController = TextEditingController();
  final TextEditingController _nonVegController = TextEditingController();
  final TextEditingController _providerIdController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUpInstitute() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final total = _totalController.text.trim();
    final veg = _vegController.text.trim();
    final nonVeg = _nonVegController.text.trim();
    final providerId = _providerIdController.text.trim();

    if (id.isEmpty || password.isEmpty || name.isEmpty || providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final dummyEmail = "$id@simplemeals.fake";

    try {
      // Step 1: Create the user in Firebase Authentication first.
      // This cannot be done inside a Firestore transaction.
      UserCredential uc = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: dummyEmail, password: password);
      final uid = uc.user!.uid;

      // Step 2: Run all Firestore writes in a single, atomic transaction.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final providerRef = FirebaseFirestore.instance.collection('providers').doc(providerId);
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final instituteRef = FirebaseFirestore.instance.collection('institutes').doc(uid);

        // Read the provider document to check for existence and get the current count.
        final providerDoc = await transaction.get(providerRef);
        if (!providerDoc.exists) {
          // If the provider doesn't exist, throw an error to cancel the transaction.
          throw Exception('Provider with this ID does not exist.');
        }

        // Write the new user document.
        transaction.set(userRef, {
          'role': 'institute',
          'userId': id,
          'email': dummyEmail,
          'name': name,
          'totalStudents': int.tryParse(total) ?? 0,
          'vegStudents': int.tryParse(veg) ?? 0,
          'nonVegStudents': int.tryParse(nonVeg) ?? 0,
          'uid': uid,
          'providerId': providerId,
        });

        // Write the new institute document.
        transaction.set(instituteRef, {
          'profile': {
            'name': name,
            'totalStudents': int.tryParse(total) ?? 0,
            'vegStudents': int.tryParse(veg) ?? 0,
            'nonVegStudents': int.tryParse(nonVeg) ?? 0,
            'providerId': providerId,
          },
          'dailyMenu': {},
          'confirmations': {},
        });
        
        // Get the current institution count, defaulting to 0 if it doesn't exist.
        final currentCount = providerDoc.data()?['institutionCount'] ?? 0;
        // Update the provider's document with the new count.
        transaction.update(providerRef, {'institutionCount': currentCount + 1});
      });

      // If the transaction completes successfully, navigate to the dashboard.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InstitutionDashboard()),
        );
      }

    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'Institution ID already exists';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _labeledInput({required String label, bool obscureText = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

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
                          _labeledInput(label: 'Create an Institution ID', controller: _idController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Create a password', obscureText: true, controller: _passwordController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Institution Name', controller: _nameController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Provider ID', controller: _providerIdController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Current No. of Students', controller: _totalController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'No. of students prefferring Veg', controller: _vegController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'No. of students prefferring Non-Veg', controller: _nonVegController),
                          const SizedBox(height: 30),
                          _actionButtons(context, constraints.maxWidth),
                          if (_isLoading)
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
        onPressed: _isLoading ? null : _signUpInstitute,
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
