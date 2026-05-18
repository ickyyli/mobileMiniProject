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

  // Variable baru untuk simpan data murid secara automatik
  String _studentName = '';
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _fetchStudentData(); 
  }

  
  Future<void> _fetchStudentData() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _studentName = data['student_name'] ?? 'Unknown Student';
          _studentId = data['student_id'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data murid: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGuardian() async {
    if (_nameController.text.trim().isEmpty || _image == null) {
      _showSnackBar("Please enter the guardian's name and select a photo.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      String fileName = 'pickups/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      
      String imageUrl = await snapshot.ref.getDownloadURL();

      
      await FirebaseFirestore.instance.collection('pickup_requests').add({
        'parentUid': uid,
        'student_name': _studentName, // <-- Disimpan di sini
        'student_id': _studentId,     // <-- Disimpan di sini (cth: S001)
        'guardianName': _nameController.text.trim(),
        'relation': _relationController.text.trim(),
        'imageUrl': imageUrl,
        'status': 'pending',
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
            // Paparkan info murid secara automatik supaya parent tahu ini untuk anak mereka
            if (_studentName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Registering guardian for: $_studentName ($_studentId)",
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                ),
              ),
            const Text(
              "Ensure the guardian's face is clear for teacher reference.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

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

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name of Guardian",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _relationController,
              decoration: InputDecoration(
                labelText: "Relationship (e.g., Grandfather, Driver)",
                prefixIcon: const Icon(Icons.people_alt_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),

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