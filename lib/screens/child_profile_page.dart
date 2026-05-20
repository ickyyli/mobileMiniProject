import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

          String? imageUrl = userData['profileImageUrl'];
          bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
          final String studentId = userData['student_id'] ?? '';

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

                _buildInfoCard("Full Name", userData['student_name'] ?? "N/A"),
                _buildInfoCard("Age", "${userData['age'] ?? 'N/A'} Years Old"),
                _buildInfoCard("Class", userData['className'] ?? "N/A"),
                _buildInfoCard("Assigned Teacher", userData['teacherName'] ?? "Teacher Not Assigned"),

                const SizedBox(height: 12),
                _AttendanceSummaryCard(studentId: studentId),
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

class _AttendanceSummaryCard extends StatelessWidget {
  final String studentId;
  const _AttendanceSummaryCard({required this.studentId});

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .snapshots(),
      builder: (context, snapshot) {
        const int windowDays = 30;
        int presentDays = 0;
        double attendanceRate = 0;

        if (snapshot.hasData) {
          final cutoff = DateTime.now().subtract(const Duration(days: windowDays));
          final uniqueDates = <String>{};

          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['timestamp'] as Timestamp?;
            if (ts == null) continue;
            final date = ts.toDate();
            if (date.isBefore(cutoff)) continue;
            uniqueDates.add(DateFormat('yyyy-MM-dd').format(date));
          }

          presentDays = uniqueDates.length;
          attendanceRate = (presentDays / windowDays) * 100;
        }

        final int absentDays = windowDays - presentDays;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Attendance Summary (Last 30 Days)",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat("$presentDays", "Present", Colors.green),
                    _stat("$absentDays", "Absent", Colors.red),
                    _stat("${attendanceRate.toStringAsFixed(1)}%", "Rate", Colors.deepPurple),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
