import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendanceLogsPage extends StatelessWidget {
  const AttendanceLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Logs"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('studentId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No attendance records found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final Timestamp? ts = data['timestamp'];
              final DateTime time = ts?.toDate() ?? DateTime.now();

              final String status = data['status'] ?? 'Check-In';
              final bool isCheckIn = status == 'Check-In';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isCheckIn ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      isCheckIn ? Icons.login : Icons.logout,
                      color: isCheckIn ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(time),
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