import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentQrPage extends StatelessWidget {
  const StudentQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Students with QR Codes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'parent')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String name = data['student_name'] ?? "Unknown Student";
              
            
              final String studentId = data['student_id'] ?? "No ID";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("ID Short: $studentId"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Buka halaman baru untuk QR
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenQrPage(name: name, id: studentId),
                        ),
                      );
                    },
                    child: const Text("View QR"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullScreenQrPage extends StatelessWidget {
  final String name;
  final String id;

  const FullScreenQrPage({super.key, required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code: $name")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10)
                ],
              ),
              child: QrImageView(
                data: id, 
                version: QrVersions.auto,
                size: 280.0,
              ),
            ),
            const SizedBox(height: 20),
            Text("Student ID: $id", style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Close"),
            )
          ],
        ),
      ),
    );
  }
}