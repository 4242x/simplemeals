import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentAccountScreen extends StatefulWidget {
  const StudentAccountScreen({super.key});

  @override
  State<StudentAccountScreen> createState() => _StudentAccountScreenState();
}

class _StudentAccountScreenState extends State<StudentAccountScreen> {
  String? _studentName;
  String? _studentId;
  String? _foodPreference;
  bool _isLoading = true;


  String _providerName = 'N/A';
  String _providerId = 'N/A';
  String _providerEmail = 'N/A';
  String _providerAddress = 'N/A';


  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final studentData = userDoc.data();

      if (studentData != null) {
        final instituteId = studentData['instituteId'];
        if (instituteId != null) {
          final instituteDoc = await FirebaseFirestore.instance.collection('institutes').doc(instituteId).get();
          final providerId = instituteDoc.data()?['profile']?['providerId'];

          if (providerId != null) {
            final providerUserDoc = await FirebaseFirestore.instance.collection('users').doc(providerId).get();
            final providerData = providerUserDoc.data();
            if (providerData != null) {
              _providerName = providerData['providerId'] ?? 'N/A';
              _providerId = providerData['providerId'] ?? 'N/A';
              _providerEmail = providerData['email']?.replaceFirst('@simplemeals.fake', '') ?? 'N/A';
              _providerAddress = "${providerData['city']}, ${providerData['state']}";
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _studentName = studentData?['name'] ?? 'Student';
          _studentId = studentData?['userId'] ?? 'N/A';
          _foodPreference = studentData?['preference'] ?? 'N/A';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching student data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _studentName = "Error";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF90E969),
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87, size: 30),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildAccountDetailsCard(),
                const SizedBox(height: 20),
                _buildProviderDetailsCard(),
              ],
            ),
    );
  }

  Widget _buildAccountDetailsCard() {
    return Card(
      color: const Color.fromARGB(255, 246, 255, 245),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _studentName ?? 'Loading...',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Student ID: $_studentId', style: const TextStyle(fontSize: 16)),
            const Text('Password: ******', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Center(
              child: Text('Food Preference: $_foodPreference', style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90E969),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Change Food Preference'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Change Password'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderDetailsCard() {
    return Card(
      color: const Color.fromARGB(255, 246, 255, 245),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Institution's Provider Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name:', _providerName),
            _buildDetailRow('Provider ID:', _providerId),
            _buildDetailRow('Contact E-mail:', _providerEmail),
            _buildDetailRow('Address:', _providerAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
