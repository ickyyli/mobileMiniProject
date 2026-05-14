import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import StudentQrPage supaya kita boleh navigate ke sana lepas daftar
import 'student_qr_page.dart'; 

class RegisterStudentPage extends StatefulWidget {
  const RegisterStudentPage({super.key});

  @override
  State<RegisterStudentPage> createState() => _RegisterStudentPageState();
}

class _RegisterStudentPageState extends State<RegisterStudentPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _classController = TextEditingController();
  final _teacherController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _registerParent() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields (Name, Email, Password)"))
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Cipta user di Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Simpan data ke Firestore menggunakan UID dari Auth sebagai Document ID
      // Ini penting supaya studentId == UID untuk imbasan QR yang unik
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'student_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'parent',
        'is_temp_password': true, 
        'age': _ageController.text.trim(), 
        'className': _classController.text.trim(),
        'teacherName': _teacherController.text.trim(),
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully Registered! Redirecting to QR List..."), backgroundColor: Colors.green)
        );

        // 3. SELEPAS DAFTAR: Terus bawa Admin ke StudentQrPage
        // Supaya Admin boleh terus tengok QR murid yang baru didaftarkan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentQrPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register New Student"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3142),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Student Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildTextField(_nameController, "Student Name", Icons.child_care),
            _buildTextField(_ageController, "Age (e.g., 5)", Icons.cake, isNumber: true),
            _buildTextField(_classController, "Class Name", Icons.room),
            _buildTextField(_teacherController, "Class Teacher", Icons.person_pin),
            
            const SizedBox(height: 30),
            const Text("Parent Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildTextField(_emailController, "Email Parent", Icons.email),
            _buildTextField(_passwordController, "Temporary Password", Icons.lock, isPassword: true),
            
            const SizedBox(height: 30),
            _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ElevatedButton(
                  onPressed: _registerParent,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Register Student & View QR List"),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _classController.dispose();
    _teacherController.dispose();
    super.dispose();
  }
}