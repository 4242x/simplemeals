import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:simplemeals/screens/provider/provider_dashboard.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  Map<String, dynamic> _inventory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _inventory = doc.data()?['inventory'] ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching inventory: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateInventoryItem(String itemName, String quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || itemName.isEmpty || quantity.isEmpty) return;

    final providerRef =
        FirebaseFirestore.instance.collection('providers').doc(user.uid);

    await providerRef.update({'inventory.$itemName': quantity});
    _fetchInventory();
  }

  Future<void> _deleteInventoryItem(String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final providerRef =
        FirebaseFirestore.instance.collection('providers').doc(user.uid);

    await providerRef.update({'inventory.$itemName': FieldValue.delete()});
    _fetchInventory();
  }

  void _showEditItemDialog(String currentItemName, String currentQuantity) {
    final TextEditingController quantityController =
        TextEditingController(text: currentQuantity);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit "$currentItemName"'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration:
                const InputDecoration(labelText: 'Quantity (e.g., 100)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _showDeleteConfirmationDialog(currentItemName);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newQuantity = "${quantityController.text.trim()} meals";
                _updateInventoryItem(
                  currentItemName,
                  newQuantity,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "$itemName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _deleteInventoryItem(itemName);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog() {
    final TextEditingController itemController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                    labelText: 'Quantity (e.g., 100)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newQuantity = "${quantityController.text.trim()} meals";
                _updateInventoryItem(
                  itemController.text.trim(),
                  newQuantity,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 240, 227),
      appBar: AppBar(
        backgroundColor: const Color(0xFF90E969),
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProviderDashboard()),
            );
          },
        ),
        title: const Center(
          child: Text(
            'Inventory',
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
          : _inventory.isEmpty
              ? const Center(
                  child: Text(
                    'Your inventory is empty.\nTap the + button to add an item.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: _inventory.entries.map((entry) {
                    final isAvailable =
                        !entry.value.toString().toLowerCase().contains('unavail');
                    String subtitleText = entry.value;
                    if (isAvailable) {
                      final amount = entry.value.replaceAll(RegExp(r'[^0-9]'), '');
                      subtitleText = 'Available: $amount';
                    }
                    return _buildInventoryItemCard(
                      title: entry.key,
                      subtitle: subtitleText,
                      subtitleColor: isAvailable ? Colors.green : Colors.red,
                      imageColor: Colors.grey[200]!,
                      onTap: () => _showEditItemDialog(entry.key, entry.value.replaceAll(RegExp(r'[^0-9]'), '')),
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: const Color(0xFF90E969),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _buildInventoryItemCard({
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required Color imageColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 246, 255, 245),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: imageColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
