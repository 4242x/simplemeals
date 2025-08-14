import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplemeals/landing_page.dart';
import 'package:simplemeals/screens/provider/inventory_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  String? _providerName;
  int? _institutionCount;
  Map<String, dynamic> _inventoryPreview = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviderData();
  }

  Future<void> _fetchProviderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDocFuture = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final providerDocFuture = FirebaseFirestore.instance.collection('providers').doc(user.uid).get();

      final results = await Future.wait([userDocFuture, providerDocFuture]);
      
      final userDoc = results[0];
      final providerDoc = results[1];

      if (mounted) {
        final Map<String, dynamic> fullInventory = Map<String, dynamic>.from(providerDoc.data()?['inventory'] ?? {});
        setState(() {
          _providerName = userDoc.data()?['providerId'] ?? 'Provider';
          _institutionCount = providerDoc.data()?['institutionCount'] ?? 0;
          _inventoryPreview = Map<String, dynamic>.fromEntries(fullInventory.entries.take(2));
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching provider data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _providerName = "Error";
          _institutionCount = 0;
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

  Future<void> _linkInstitution(String institutionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || institutionId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final providerRef = FirebaseFirestore.instance.collection('providers').doc(user.uid);
        final institutionRef = FirebaseFirestore.instance.collection('institutes').doc(institutionId);

        final institutionDoc = await transaction.get(institutionRef);
        if (!institutionDoc.exists) {
          throw Exception('Institution with this ID does not exist.');
        }

        final institutionProviderId = institutionDoc.data()?['profile']?['providerId'];
        if (institutionProviderId != user.uid) {
          throw Exception('This institution is not linked to your provider account.');
        }
        
        final providerDoc = await transaction.get(providerRef);
        final currentCount = providerDoc.data()?['institutionCount'] ?? 0;
        transaction.update(providerRef, {'institutionCount': currentCount + 1});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Institution linked successfully!'), backgroundColor: Colors.green),
      );
      await _fetchProviderData();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddSchoolDialog() {
    final TextEditingController institutionIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Link an Institution'),
          content: TextField(
            controller: institutionIdController,
            decoration: const InputDecoration(labelText: 'Enter Institution ID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _linkInstitution(institutionIdController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
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
                _buildWelcomeCard(newColor),
                const SizedBox(height: 20),
                _buildTopSection(context, newColor),
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
              'Hello, $_providerName.',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check out your available inventory for today. $_institutionCount schools are expecting meals today.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, Color cardColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildAddSchoolCard(cardColor),
              const SizedBox(height: 10),
              _buildLogisticsCard(),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: _buildInventoryCard(context)),
      ],
    );
  }

  Widget _buildAddSchoolCard(Color cardColor) {
    return GestureDetector(
      onTap: _showAddSchoolDialog,
      child: Card(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 32, color: Colors.black87),
              SizedBox(width: 15),
              Text(
                'Add a\nschool',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        color: Colors.blueGrey[300],
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'View\nInstitution\nLogistics →',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context) {
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
                'Inventory',
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
            child: Column(
              children: [
                if (_inventoryPreview.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'Your inventory is empty.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  ..._inventoryPreview.entries.map((entry) {
                    final isAvailable = !entry.value.toString().toLowerCase().contains('unavail');
                    String subtitleText = entry.value;
                    if (isAvailable) {
                      final amount = entry.value.replaceAll(RegExp(r'[^0-9]'), '');
                      subtitleText = 'Available: $amount';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _inventoryItem(
                        entry.key,
                        subtitleText,
                        isAvailable ? Colors.green : Colors.red,
                        Colors.grey[200]!,
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    ),
                    child: const Text(
                      'Click to access →',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryItem(
    String title,
    String subtitle,
    Color subtitleColor,
    Color imageColor,
  ) {
    return Row(
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
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: imageColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
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

                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No feedback available.', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
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
