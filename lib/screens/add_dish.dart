import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class AddDishScreen extends StatefulWidget {
  const AddDishScreen({super.key});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();

  // helpers---
  static Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Updated Helper
  static Widget _textField(
    String hint,
    TextEditingController controller, { // Controller connection added
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller, // Essential for Firestore
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

int _currentQuantity = 0; // for button

class _AddDishScreenState extends State<AddDishScreen> {
  // Controllers defined inside State
  final _dishnameController = TextEditingController();
  final _dishDescription = TextEditingController();
  final _dishPrice = TextEditingController();
  final _dishQntAvailable = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _dishnameController.dispose();
    _dishDescription.dispose();
    _dishPrice.dispose();
    _dishQntAvailable.dispose();
    super.dispose();
  }

  //  Firestore Save Function
  Future<void> _saveDish() async {
    // Basic Check
    if (_dishnameController.text.isEmpty ||
        _dishPrice.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 'Dish' collection data sending to db
      await FirebaseFirestore.instance.collection('Dish').add({
        'name': _dishnameController.text.trim(),
        'description': _dishDescription.text.trim(),
        'price': int.parse(_dishPrice.text.trim()),
        'category': _selectedCategory,
        'created_at': DateTime.now(),
        "qnt_available": _currentQuantity,
        "restaurant_id": FirebaseAuth.instance.currentUser?.uid,
        "image": [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dish saved successfully!")),
        );
        Navigator.pop(context); // Go back after success
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: const Text("Add Dish", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddDishScreen._label("Dish Name"),
            AddDishScreen._textField("Enter dish name", _dishnameController),

            AddDishScreen._label("Description"),
            AddDishScreen._textField(
              "Short description",
              _dishDescription,
              maxLines: 3,
            ),

            AddDishScreen._label("Price"),
            AddDishScreen._textField(
              "Enter price",
              _dishPrice,
              keyboardType: TextInputType.number,
            ),

            AddDishScreen._label("Category"),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: "Starters", child: Text("Starters")),
                DropdownMenuItem(value: "Mains", child: Text("Mains")),
                DropdownMenuItem(value: "Desserts", child: Text("Desserts")),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value); // Update variable
              },
              decoration: AddDishScreen._inputDecoration("Select category"),
            ),

            const SizedBox(height: 20),

            AddDishScreen._label("Quantity Available"),
            Row(
              children: [
                // for minus
                GestureDetector(
                  onTap: () {
                    if (_currentQuantity > 0) {
                      setState(() => _currentQuantity--);
                    }
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    color: Colors.red[400],
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),

                Container(
                  width: 45,
                  height: 45,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Text(
                    "$_currentQuantity ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // add
                GestureDetector(
                  onTap: () {
                    setState(() => _currentQuantity++);
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    color: Colors.red[400],
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // for image placeholder
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text("Upload Dish Image"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Call _saveDish when clicked
              onPressed: _isLoading ? null : _saveDish,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Dish",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
