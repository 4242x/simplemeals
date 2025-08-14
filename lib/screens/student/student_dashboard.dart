import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import 'package:simplemeals/landing_page.dart';
import 'package:simplemeals/screens/student/account_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String? _studentName;
  bool _isLoading = true;
  final TextEditingController _feedbackController = TextEditingController();

  double _attendanceRate = 0.0;
  int _daysPresent = 0;
  int _totalDays = 0;
  bool? _todaysAttendance;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _getTodaysDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _fetchStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDocFuture = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final studentDocFuture = FirebaseFirestore.instance.collection('students').doc(user.uid).get();

      final results = await Future.wait([userDocFuture, studentDocFuture]);
      final userDoc = results[0];
      final studentDoc = results[1];

      if (mounted) {
        final attendanceData = studentDoc.data()?['attendance'] as Map<String, dynamic>? ?? {};
        _totalDays = attendanceData.length;
        _daysPresent = attendanceData.values.where((present) => present == true).length;
        _attendanceRate = _totalDays > 0 ? (_daysPresent / _totalDays) * 100 : 0.0;
        _todaysAttendance = attendanceData[_getTodaysDateKey()];

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

  Future<void> _markAttendance(bool attended) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayKey = _getTodaysDateKey();
    try {
      await FirebaseFirestore.instance.collection('students').doc(user.uid).update({
        'attendance.$todayKey': attended,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked for today.'), backgroundColor: Colors.green),
      );
      _fetchStudentData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking attendance: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback before submitting.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green),
    );
    _feedbackController.clear();
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if(mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(onPressed: _signOut, icon: const Icon(Icons.menu)),
        backgroundColor: const Color(0xFF90E969),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SimpleMeals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
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
                _buildMealConfirmationCard(),
                const SizedBox(height: 20),
                _buildMealInsightsCard(),
              ],
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: const Color.fromARGB(255, 227, 255, 227),
      elevation: 0,
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
              "Welcome back! Here's an overview of your mid-day program progress.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      color: const Color.fromARGB(255, 227, 255, 227),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatBox('${_attendanceRate.toStringAsFixed(1)}%')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatBox('$_daysPresent/$_totalDays days')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMealConfirmationCard() {
    return Card(
      color: const Color.fromARGB(255, 227, 255, 227),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Did you get your meal today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_todaysAttendance != null)
              Text(
                _todaysAttendance! ? "You marked: Yes" : "You marked: No",
                style: TextStyle(
                  color: _todaysAttendance! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markAttendance(true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Yes'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markAttendance(false),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('No'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealInsightsCard() {
    return Card(
      color: const Color(0xFFC8E6C9),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mid-Day Meal Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: const Text('Analysis'),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('All meals were received during this month\'s program.'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Chip(label: Text('Feedback')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackController,
                      decoration: const InputDecoration(
                        hintText: 'Type your comments...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _submitFeedback,
                        child: const Text('Submit →'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
