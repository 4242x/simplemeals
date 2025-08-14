import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InstitutionFeedbackScreen extends StatefulWidget {
  const InstitutionFeedbackScreen({super.key});

  @override
  State<InstitutionFeedbackScreen> createState() => _InstitutionFeedbackScreenState();
}

class _InstitutionFeedbackScreenState extends State<InstitutionFeedbackScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _feedbackList = [];
  Map<String, dynamic>? _providerDetails;

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
      // Fetch feedback for the current institution
      final feedbackSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('institutionId', isEqualTo: user.uid)
          .get();
      
      _feedbackList = feedbackSnapshot.docs.map((doc) => doc.data()).toList();

      // Fetch provider details
      final instituteDoc = await FirebaseFirestore.instance.collection('institutes').doc(user.uid).get();
      final providerId = instituteDoc.data()?['profile']?['providerId'];

      if (providerId != null) {
        final providerUserDoc = await FirebaseFirestore.instance.collection('users').doc(providerId).get();
        _providerDetails = providerUserDoc.data();
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching data: $e");
      if (mounted) setState(() => _isLoading = false);
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
            'Feedback',
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
                ..._feedbackList.map((feedback) => _buildFeedbackCard(feedback)),
                const SizedBox(height: 20),
                if (_providerDetails != null) _buildProviderDetailsCard(),
              ],
            ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final bool isSatisfied = feedback['status'] == 'Satisfied';
    return Card(
      color: const Color.fromARGB(255, 246, 255, 245),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.account_circle, size: 40, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback['name'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Status: '),
                      Text(
                        feedback['status'] ?? 'N/A',
                        style: TextStyle(
                          color: isSatisfied ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Comments: ${feedback['comments'] ?? 'N/A'}'),
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
            const Center(
              child: Text(
                "Provider Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name:', _providerDetails?['providerId'] ?? 'N/A'),
            _buildDetailRow('Contact Number:', '+91 77778XXXXX'), // Placeholder
            _buildDetailRow('Contact E-mail:', _providerDetails?['email']?.replaceFirst('@simplemeals.fake', '') ?? 'N/A'),
            _buildDetailRow('Address:', '${_providerDetails?['city']}, ${_providerDetails?['state']}'),
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
