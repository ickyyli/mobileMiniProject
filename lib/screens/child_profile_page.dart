import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildProfilePage extends StatelessWidget {
  const ChildProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ID user yang sedang log masuk
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Child Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        // Anda perlu pastikan dokumen ID dalam Firestore sama dengan UID user
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data child profile not found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    backgroundImage: userData['profileImageUrl'] != null 
                        ? NetworkImage(userData['profileImageUrl']) 
                        : null,
                    child: userData['profileImageUrl'] == null 
                        ? const Icon(Icons.person, size: 80, color: Colors.white) 
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard("Full Name", userData['fullName'] ?? "N/A"),
                _buildInfoCard("Age", "${userData['age'] ?? 'N/A'} Years Old"),
                _buildInfoCard("Class", userData['className'] ?? "N/A"),
                _buildInfoCard("Assigned Teacher", userData['teacherName'] ?? "Assigning..."),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}