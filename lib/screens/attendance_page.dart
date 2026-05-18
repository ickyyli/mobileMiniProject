import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';


class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Attendance",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.qr_code_2_rounded), text: "My QR"),
              Tab(icon: Icon(Icons.history_rounded), text: "Logs"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StudentQRCodePage(), 
            AttendanceLogsPage(), 
          ],
        ),
      ),
    );
  }
}


class StudentQRCodePage extends StatelessWidget {
  const StudentQRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data profil tidak ditemui"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          // Mengambil student_id pendek (Contoh: "S002") dari Firestore
          final String studentId = userData['student_id'] ?? "Tiada ID";

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Show this QR code to the teacher for attendance",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: QrImageView(
                      data: studentId, 
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Student ID: $studentId",
                    style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class AttendanceLogsPage extends StatelessWidget {
  const AttendanceLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in again."));
    }

    final String parentUid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(parentUid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("Profile not found."));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          // Membaca student_id pendek ("S002") dari profil parent
          final String? shortStudentId = userData['student_id'];

          if (shortStudentId == null || shortStudentId.isEmpty) {
            return const Center(child: Text("No student ID linked."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .where('studentId', isEqualTo: shortStudentId) // Tapis guna ID pendek
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // JIKA DAH DELETED / TIADA REKOD: Papar skrin kosong yang kemas tanpa dummy
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 15),
                      Text(
                        "No attendance records for today",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Logs will be displayed after teacher scan.",
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  final Timestamp? ts = data['timestamp'];
                  final DateTime time = ts?.toDate() ?? DateTime.now();

                  final String status = data['status'] ?? 'Check-In';
                  final bool isCheckIn = status == 'Check-In';

                  return Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: isCheckIn ? Colors.green[50] : Colors.red[50],
                        child: Icon(
                          isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                          color: isCheckIn ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        status,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          DateFormat('dd MMM yyyy - hh:mm a').format(time),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}