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
        body: Center(child: Text("Please log in to view attendance logs.")),
      );
    }

    final String parentUid = user.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          final String? shortStudentId = userData['student_id'];

          if (shortStudentId == null || shortStudentId.isEmpty) {
            return const Center(child: Text("No student ID linked."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .where('studentId', isEqualTo: shortStudentId) 
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

            
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