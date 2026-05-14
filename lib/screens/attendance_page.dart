import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil UID parent yang login (digunakan sebagai studentId)
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Rekod Kehadiran Murid", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.deepPurple[100],
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen kepada koleksi 'attendance' secara real-time berdasarkan studentId
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('studentId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Ralat memuatkan data."));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text("Tiada rekod kehadiran ditemui.", 
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              
              // Safely handle timestamp
              DateTime dateTime = DateTime.now();
              if (data['timestamp'] != null) {
                dateTime = (data['timestamp'] as Timestamp).toDate();
              }
              
              String status = data['status'] ?? "Unknown";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: status == "Check-In" ? Colors.green[50] : Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == "Check-In" ? Icons.login_rounded : Icons.logout_rounded,
                      color: status == "Check-In" ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(status, 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                  subtitle: Text(
                    DateFormat('EEEE, dd MMM yyyy\nhh:mm a').format(dateTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}