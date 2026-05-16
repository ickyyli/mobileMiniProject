import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_log_page.dart';

class StudentSelectionPage extends StatelessWidget {
  const StudentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Student'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching parents who have a student assigned
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'parent')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Get the document snapshot
              var doc = snapshot.data!.docs[index];

              // Convert to a Map safely
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // Extract fields with fallback values to avoid null errors
              String studentName = data['student_name'] ?? 'Unknown Student';
              String studentId = data['student_id'] ??
                  doc.id; // Fallback to Firestore Doc ID if student_id is missing
              String className = data['className'] ?? 'Not Assigned';

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(studentName),
                subtitle:
                    Text('Class: $className'), // Using the variable from Step 1
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityLogPage(
                        studentId: studentId,
                        studentName: studentName,
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
