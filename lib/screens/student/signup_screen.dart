import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/screens/student/login_screen.dart';
import 'package:simplemeals/screens/student/student_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _institutionIdController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  String? _selectedPreference;
  bool _isLoading = false;

  Future<void> _signUpStudent() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final institutionId = _institutionIdController.text.trim();
    final age = _ageController.text.trim();
    final pref = _selectedPreference;

    if (id.isEmpty || password.isEmpty || name.isEmpty || institutionId.isEmpty || pref == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final dummyEmail = "$id@simplemeals.fake";
    UserCredential? uc;

    try {
      final institutionQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'institute')
          .where('userId', isEqualTo: institutionId)
          .limit(1)
          .get();

      if (institutionQuery.docs.isEmpty) {
        throw Exception('Institution with this ID does not exist.');
      }
      
      final institutionUid = institutionQuery.docs.first.id;

      uc = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: dummyEmail, password: password);
      final uid = uc.user!.uid;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final institutionRef = FirebaseFirestore.instance.collection('institutes').doc(institutionUid);
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final studentRef = FirebaseFirestore.instance.collection('students').doc(uid);

        final institutionDoc = await transaction.get(institutionRef);
        if (!institutionDoc.exists) {
          throw Exception('Institution data not found.');
        }

        transaction.set(userRef, {
          'role': 'student',
          'userId': id,
          'email': dummyEmail,
          'name': name,
          'instituteId': institutionUid,
          'age': int.tryParse(age),
          'preference': pref,
          'uid': uid,
        });

        transaction.set(studentRef, {
          'profile': {
            'name': name,
            'instituteId': institutionUid,
            'age': int.tryParse(age),
            'preference': pref,
          },
          'attendance': {},
        });
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Signup failed';
      if (e.code == 'email-already-in-use') message = 'User ID already exists';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (uc != null) {
        await uc.user?.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}')));
    } finally {
      if (mounted) {
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
          keyboardType: label.toLowerCase().contains('age') ? TextInputType.number : TextInputType.text,
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

  Widget _buildPreferenceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select food preference', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPreference,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: const Text('Select Preference'),
          items: ['Veg', 'Non-Veg'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedPreference = newValue;
            });
          },
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
                              'Student - Sign Up',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _labeledInput(label: 'Create an User ID', controller: _idController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Create a password', obscureText: true, controller: _passwordController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Name', controller: _nameController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Institution ID', controller: _institutionIdController),
                          const SizedBox(height: 20),
                          _labeledInput(label: 'Age', controller: _ageController),
                          const SizedBox(height: 20),
                          _buildPreferenceDropdown(),
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
        onPressed: _isLoading ? null : _signUpStudent,
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
            MaterialPageRoute(builder: (context) => const StudentLoginScreen()),
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
