import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/landing_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String? _studentName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (mounted) {
        setState(() {
          _studentName = userDoc.data()?['name'] ?? 'Student';
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(onPressed: () => _signOut(context), icon: const Icon(Icons.arrow_back)),
        backgroundColor: const Color(0xFF90E969),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                _buildAttendanceCard(),
                const SizedBox(height: 20),
                _buildMealConsumptionCard(),
              ],
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $_studentName.',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Welcome back! Here's an overview of your SimpleMeals program progress.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('94.6%', 'Attendance Rate'),
                _buildStatColumn('142 / 150', 'Days Present'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealConsumptionCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Consumption Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('23', 'Meals Consumed This Month'),
                _buildStatColumn('Curry Rice', 'Favorite Meal'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Meals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMealItem('Dal & Rice (Along with Fruit)', 'Oct 26, 2023', consumed: true),
            const SizedBox(height: 12),
            _buildMealItem('Vegetable Soup', 'Oct 25, 2023', consumed: false),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All Meals', style: TextStyle(color: Colors.black54)),
                    Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildMealItem(String meal, String date, {required bool consumed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Chip(
          label: Text(
            consumed ? 'Consumed' : 'Skipped',
            style: TextStyle(color: consumed ? Colors.green : Colors.red),
          ),
          backgroundColor: consumed ? const Color.fromARGB(255, 234, 240, 234) : const Color.fromARGB(255, 237, 224, 224),
          side: BorderSide.none,
        ),
      ],
    );
  }
}
