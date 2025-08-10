import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/landing_page.dart';
import 'package:simplemeals/screens/institution/institution_account_screen.dart';
import 'package:simplemeals/screens/institution/menu_planner_screen.dart';

class InstitutionDashboard extends StatefulWidget {
  const InstitutionDashboard({super.key});

  @override
  State<InstitutionDashboard> createState() => _InstitutionDashboardState();
}

class _InstitutionDashboardState extends State<InstitutionDashboard> {
  String? _institutionName;
  int _studentCount = 0;
  Map<String, dynamic> _todaysMenu = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInstitutionData();
  }

  Future<void> _fetchInstitutionData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDocFuture = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final instituteDocFuture = FirebaseFirestore.instance.collection('institutes').doc(user.uid).get();

      final results = await Future.wait([userDocFuture, instituteDocFuture]);
      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final instituteDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _institutionName = userDoc.data()?['name'] ?? 'Institution';
          _studentCount = instituteDoc.data()?['profile']?['totalStudents'] ?? 0;
          _todaysMenu = instituteDoc.data()?['dailyMenu'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching institution data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _institutionName = "Error";
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
    const newColor = Color.fromARGB(255, 226, 255, 226);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF90E969),
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
          onPressed: _showLogoutConfirmationDialog,
        ),
        title: const Center(
          child: Text(
            'SimpleMeals',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InstitutionAccountScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildWelcomeCard(newColor),
                const SizedBox(height: 20),
                _buildTodaysMenuCard(),
                const SizedBox(height: 20),
                _buildInsightsAndFeedbackCard(),
              ],
            ),
    );
  }

  Widget _buildWelcomeCard(Color cardColor) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $_institutionName.',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You will be receiving meals for $_studentCount students tomorrow. Please appropriately prepare and ensure proper distribution.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMenuCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF90E969),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Center(
              child: Text(
                'Today\'s Menu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Container(
            color: const Color.fromARGB(255, 246, 255, 245),
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              child: Column(
                children: [
                  if (_todaysMenu.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('No menu set for today.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                  ..._todaysMenu.entries.map((entry) {
                    return _menuItem(entry.key, entry.value);
                  }).toList(),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuPlannerScreen()),
                        );
                        _fetchInstitutionData();
                      },
                      child: const Text(
                        'Click to access →',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsAndFeedbackCard() {
    const cardBodyColor = Color.fromARGB(255, 226, 255, 226);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF90E969),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Center(
              child: Text(
                'Attendance Insights & Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Container(
            color: cardBodyColor,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: const Text('Analysis'),
                      backgroundColor: cardBodyColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '0% more or 0 students attended school yesterday than the day before.',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Center(
                          child: Chip(
                            label: const Text('Feedback'),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _feedbackItem(
                          'Yash from Class 12 reported of not receiving his meals on last Tuesday',
                        ),
                        const Divider(height: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Click to view more →',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackItem(String text) {
    return Row(
      children: [
        const Icon(Icons.person_pin, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
