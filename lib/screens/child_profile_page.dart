import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Profile"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data child profile not found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // Ambil URL gambar, cek jika null atau kosong
          String? imageUrl = userData['profileImageUrl'];
          bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                    child: !hasImage 
                        ? const Icon(Icons.person, size: 80, color: Colors.white) 
                        : null,
                  ),
                ),
                const SizedBox(height: 30),
                
                // MENGGUNAKAN 'student_name' SEPERTI DI DATABASE
                _buildInfoCard("Full Name", userData['student_name'] ?? "N/A"),
                
                _buildInfoCard("Age", "${userData['age'] ?? 'N/A'} Years Old"),
                _buildInfoCard("Class", userData['className'] ?? "N/A"),
                _buildInfoCard("Assigned Teacher", userData['teacherName'] ?? "Teacher Not Assigned"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }
}