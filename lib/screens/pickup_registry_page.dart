import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PickupRegistryPage extends StatefulWidget {
  const PickupRegistryPage({super.key});

  @override
  State<PickupRegistryPage> createState() => _PickupRegistryPageState();
}

class _PickupRegistryPageState extends State<PickupRegistryPage> {
  File? _image;
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = false;

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Mengurangkan saiz fail untuk jimat storage
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi utama untuk simpan ke Firebase
  Future<void> _saveGuardian() async {
    // Validasi input
    if (_nameController.text.trim().isEmpty || _image == null) {
      _showSnackBar("Please enter the guardian's name and select a photo.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // 1. MUAT NAIK GAMBAR KE FIREBASE STORAGE
      String fileName = 'pickups/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      
      // Dapatkan URL gambar yang telah diupload
      String imageUrl = await snapshot.ref.getDownloadURL();

      // 2. SIMPAN DATA KE CLOUD FIRESTORE
      await FirebaseFirestore.instance.collection('pickup_requests').add({
        'parentUid': uid,
        'guardianName': _nameController.text.trim(),
        'relation': _relationController.text.trim(),
        'imageUrl': imageUrl,
        'status': 'pending', // Menunggu pengesahan admin/guru
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar("Guardian registered successfully!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: $e", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup Registry"),
        backgroundColor: Colors.deepPurple[50],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Register Authorized Guardian",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ensure the guardian's face is clear for teacher reference.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Bahagian Gambar
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2)),
                  ),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text("Add Photo", style: TextStyle(color: Colors.deepPurple)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Input Nama
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name of Guardian",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Input Hubungan
            TextField(
              controller: _relationController,
              decoration: InputDecoration(
                labelText: "Relationship (e.g., Grandfather, Driver)",
                prefixIcon: const Icon(Icons.people_alt_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

            // Butang Hantar
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveGuardian,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Submit Application", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }
}