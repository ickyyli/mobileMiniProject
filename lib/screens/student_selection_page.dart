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
              var userData = snapshot.data!.docs[index];
              // Using student_name from your Firestore structure
              String studentName =
                  userData['student_name'] ?? 'Unknown Student';
              // This is the ID you manually added to the console
              // This checks if the data map contains the key before trying to read it
              Map<String, dynamic> data =
                  userData.data() as Map<String, dynamic>;
              String studentId =
                  data.containsKey('student_id') ? data['student_id'] : 'No-ID';

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(studentName),
                subtitle: Text('Class: ${userData['className']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Now we pass the REQUIRED parameters to the log page
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
