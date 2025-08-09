import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
      body: ListView(
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
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Yash.',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
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
