import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InstitutionAccountScreen extends StatefulWidget {
  const InstitutionAccountScreen({super.key});

  @override
  State<InstitutionAccountScreen> createState() => _InstitutionAccountScreenState();
}

class _InstitutionAccountScreenState extends State<InstitutionAccountScreen> {
  bool _isLoading = true;
  String _institutionName = 'N/A';
  String _institutionId = 'N/A';
  int _totalStudents = 0;
  int _vegStudents = 0;
  int _nonVegStudents = 0;

  String _providerName = 'N/A';
  String _providerId = 'N/A';
  String _providerContact = 'N/A';
  String _providerEmail = 'N/A';
  String _providerAddress = 'N/A';


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final institutionData = userDoc.data();

      if (institutionData != null) {
        _institutionName = institutionData['name'] ?? 'N/A';
        _institutionId = institutionData['userId'] ?? 'N/A';
        _totalStudents = institutionData['totalStudents'] ?? 0;
        _vegStudents = institutionData['vegStudents'] ?? 0;
        _nonVegStudents = institutionData['nonVegStudents'] ?? 0;
        
        final providerUid = institutionData['providerId'];
        if (providerUid != null) {
          final providerUserDoc = await FirebaseFirestore.instance.collection('users').doc(providerUid).get();
          final providerData = providerUserDoc.data();
          if (providerData != null) {
            _providerName = providerData['providerId'] ?? 'N/A'; // Assuming provider's name is stored in providerId field
            _providerId = providerData['providerId'] ?? 'N/A';
            _providerContact = providerData['contactNumber'] ?? '+91 77778XXXXX'; // Placeholder
            _providerEmail = providerData['email']?.replaceFirst('@simplemeals.fake', '') ?? 'N/A';
            _providerAddress = "${providerData['city']}, ${providerData['state']}";
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _institutionName = "Error";
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
          icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
          onPressed: () {},
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
                _buildSubscriptionCard(),
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
              _institutionName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Institution ID: $_institutionId', style: const TextStyle(fontSize: 16)),
            const Text('Password: ******', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Total No. of Students: $_totalStudents', style: const TextStyle(fontSize: 16)),
            Text('Vegetarians: $_vegStudents', style: const TextStyle(fontSize: 16)),
            Text('Non-Vegetarians: $_nonVegStudents', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90E969),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Increase No. of Students'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
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

  Widget _buildSubscriptionCard() {
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
              "App Subscription",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Thank you for using and trying this app. We would like to offer our subscription plan.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Basic Plan:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹1000"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Duration:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("1 month", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ],
              ),
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
              "Provider Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name:', _providerName),
            _buildDetailRow('Provider ID:', _providerId),
            _buildDetailRow('Contact Number:', _providerContact),
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
