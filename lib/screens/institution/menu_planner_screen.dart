import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class MenuPlannerScreen extends StatefulWidget {
  const MenuPlannerScreen({super.key});

  @override
  State<MenuPlannerScreen> createState() => _MenuPlannerScreenState();
}

class _MenuPlannerScreenState extends State<MenuPlannerScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic> _providerInventory = {};
  Map<String, TextEditingController> _menuItemControllers = {};
  final TextEditingController _menuTitleController = TextEditingController();
  String? _nutritionalAnalysis;

  @override
  void initState() {
    super.initState();
    _fetchProviderInventory();
  }

  @override
  void dispose() {
    for (var controller in _menuItemControllers.values) {
      controller.dispose();
    }
    _menuTitleController.dispose();
    super.dispose();
  }

  Future<void> _fetchProviderInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final instituteDoc = await FirebaseFirestore.instance.collection('institutes').doc(user.uid).get();
      final providerId = instituteDoc.data()?['profile']?['providerId'];

      if (providerId != null) {
        final providerDoc = await FirebaseFirestore.instance.collection('providers').doc(providerId).get();
        if (mounted) {
          setState(() {
            _providerInventory = providerDoc.data()?['inventory'] ?? {};
            _providerInventory.forEach((key, value) {
              _menuItemControllers[key] = TextEditingController();
            });
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching provider inventory: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndAnalyzeMenu() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> dailyMenu = {};
    _menuItemControllers.forEach((key, controller) {
      final quantity = controller.text.trim();
      if (quantity.isNotEmpty && int.tryParse(quantity) != null && int.parse(quantity) > 0) {
        final originalValue = _providerInventory[key].toString();
        final unit = originalValue.split(' ').last;
        dailyMenu[key] = '$quantity $unit';
      }
    });

    try {
      await FirebaseFirestore.instance.collection('institutes').doc(user.uid).update({
        'dailyMenu': dailyMenu,
        'dailyMenuTitle': _menuTitleController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu saved! Generating analysis...'), backgroundColor: Colors.green),
      );

      // After saving, get nutritional analysis from Gemini
      await _getNutritionalAnalysis(dailyMenu.keys.toList());

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving menu: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _getNutritionalAnalysis(List<String> menuItems) async {
    if (menuItems.isEmpty) {
      setState(() => _nutritionalAnalysis = "No items selected for analysis.");
      return;
    }

    final gemini = Gemini.instance;
    final prompt = "Provide a brief nutritional analysis (calories, protein, fibre) for a meal consisting of these items: ${menuItems.join(', ')}. Be very concise.";

    try {
      final response = await gemini.text(prompt);
      // **FIXED:** Use response.output to get the text directly.
      final analysis = response?.output;
      setState(() {
        _nutritionalAnalysis = analysis;
      });
    } catch (e) {
      setState(() {
        _nutritionalAnalysis = "Could not generate analysis at this time.";
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(
          child: Text(
            'Menu Planner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.transparent), 
            onPressed: null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providerInventory.isEmpty
              ? const Center(
                  child: Text(
                    'Your provider has not set up their inventory.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildTitleCard(),
                    const SizedBox(height: 16),
                    ..._providerInventory.entries.map((entry) {
                      return _buildMenuItem(entry.key, entry.value);
                    }),
                    if (_nutritionalAnalysis != null) _buildAnalysisCard(),
                    const SizedBox(height: 80),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveAndAnalyzeMenu,
        backgroundColor: const Color(0xFF90E969),
        icon: _isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black87))
            : const Icon(Icons.save, color: Colors.black87),
        label: Text(_isSaving ? 'Saving...' : 'Save & Analyze', style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  Widget _buildTitleCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          controller: _menuTitleController,
          decoration: const InputDecoration(
            labelText: 'Menu Title (e.g., Monday Special)',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String subtitle) {
    final isAvailable = !subtitle.toLowerCase().contains('unavail');

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
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _menuItemControllers[title],
                enabled: isAvailable,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Qty',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      color: const Color.fromARGB(255, 220, 237, 200),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutritional Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_nutritionalAnalysis ?? 'Analysis not available.'),
          ],
        ),
      ),
    );
  }
}
