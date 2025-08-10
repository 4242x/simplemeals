import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/landing_page.dart';
import 'package:simplemeals/screens/student/account_screen.dart'; // Import the new screen

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String? _studentName;
  bool _isLoading = true;

  // State variables for dynamic data
  double _attendanceRate = 0.0;
  int _daysPresent = 0;
  int _totalDays = 0;
  int _mealsConsumed = 0;
  String _favoriteMeal = 'N/A';
  List<Map<String, dynamic>> _recentMeals = [];


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
      // Fetch both user and student documents
      final userDocFuture = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final studentDocFuture = FirebaseFirestore.instance.collection('students').doc(user.uid).get();

      final results = await Future.wait([userDocFuture, studentDocFuture]);
      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final studentDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;


      if (mounted) {
        // --- Data Processing Logic ---
        final attendanceData = studentDoc.data()?['attendance'] as Map<String, dynamic>? ?? {};
        _totalDays = attendanceData.length;
        _daysPresent = attendanceData.values.where((present) => present == true).length;
        _attendanceRate = _totalDays > 0 ? (_daysPresent / _totalDays) * 100 : 0.0;

        // This is a placeholder for meal data logic. You'll need to adapt it
        // to how you plan to store meal consumption.
        _mealsConsumed = 0; // Replace with actual logic
        _favoriteMeal = 'N/A'; // Replace with actual logic
        _recentMeals = []; // Replace with actual logic


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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(onPressed: _showLogoutConfirmationDialog, icon: const Icon(Icons.logout)),
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
        actions: [ // Add actions list for the new button
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudentAccountScreen()),
              );
            },
          ),
        ],
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
                _buildStatColumn('${_attendanceRate.toStringAsFixed(1)}%', 'Attendance Rate'),
                _buildStatColumn('$_daysPresent / $_totalDays', 'Days Present'),
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
                _buildStatColumn('$_mealsConsumed', 'Meals Consumed This Month'),
                _buildStatColumn(_favoriteMeal, 'Favorite Meal'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Meals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_recentMeals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('No recent meals to show.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._recentMeals.map((meal) => _buildMealItem(
                meal['name'] ?? 'N/A',
                meal['date'] ?? 'N/A',
                consumed: meal['consumed'] ?? false,
              )),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
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
      ),
    );
  }
}
