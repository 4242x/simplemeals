import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInventoryItemCard(
            title: 'Eggs',
            subtitle: 'Unavailable: Refill',
            subtitleColor: Colors.red,
            imageColor: Colors.yellow[100]!,
          ),
          _buildInventoryItemCard(
            title: 'Rice & Dal',
            subtitle: 'Available: 100 meals',
            subtitleColor: Colors.green,
            imageColor: Colors.orange[100]!,
          ),
          _buildInventoryItemCard(
            title: 'Bananas',
            subtitle: 'Available: 40 portions',
            subtitleColor: Colors.green,
            imageColor: Colors.yellow[200]!,
          ),
          _buildInventoryItemCard(
            title: 'Milk',
            subtitle: 'Available: 30 portions',
            subtitleColor: Colors.green,
            imageColor: Colors.blue[50]!,
          ),
          _buildInventoryItemCard(
            title: 'Chicken Curry',
            subtitle: 'Available: 90 meals',
            subtitleColor: Colors.green,
            imageColor: Colors.red[100]!,
          ),
          _buildInventoryItemCard(
            title: 'Vegetable Curry',
            subtitle: 'Available: 100 meals',
            subtitleColor: Colors.green,
            imageColor: Colors.green[100]!,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemCard({
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required Color imageColor,
  }) {
    return Card(
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
    );
  }
}
