import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambah ini untuk Firestore
import 'teacher_pickup_approval_page.dart'; // Tambah ini untuk navigasi page approval
import 'broadcast_announcement.dart';
import 'qr_scanner_page.dart';
import 'student_selection_page.dart';
import 'student_list_page.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  // Simple function to handle logout
  void _logout(BuildContext context) async {
    // 1. Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // 2. Navigate back to the LoginPage (the '/' route we defined in main.dart)
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('KindiSync: Teacher Portal'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Teacher!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const Text(
                'Let’s manage your class for today.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Grid for your specific Teacher Module tasks
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _dashboardItem(
                    context,
                    'Daily Attendance',
                    Icons.qr_code_2,
                    Colors.blueAccent,
                    () {
                      // Updated to navigate to the QR Scanner
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const QRScannerPage()),
                      );
                    },
                  ),
                  _dashboardItem(
                    context,
                    'Student List',
                    Icons.groups_rounded,
                    Colors.orangeAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StudentListPage()),
                      );
                    },
                  ),
                  _dashboardItem(
                    context,
                    'Daily Activity',
                    Icons.menu_book_rounded,
                    Colors.greenAccent,
                    () {
                      // Navigates to your new activity logging page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StudentSelectionPage()),
                      );
                    },
                  ),
                  _dashboardItem(
                    context,
                    'Send Broadcast',
                    Icons.campaign,
                    Colors.purpleAccent,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const BroadcastAnnouncement()),
                      );
                    },
                  ),
                ],
              ),
              
              
              const SizedBox(height: 25),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pickup_requests')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  int pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TeacherPickupApprovalPage()),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.amber[50],
                        child: const Icon(Icons.assignment_ind_rounded, color: Colors.amber, size: 28),
                      ),
                      title: const Text(
                        "Guardian Pickup Requests",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        pendingCount > 0 
                            ? "$pendingCount request(s) waiting for approval" 
                            : "No pending requests",
                        style: TextStyle(
                          color: pendingCount > 0 ? Colors.redAccent : Colors.grey,
                          fontWeight: pendingCount > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      trailing: pendingCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent, 
                                shape: BoxShape.circle
                              ),
                              child: Text(
                                "$pendingCount",
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ),
                  );
                },
              ),
              // === TAMAT INPUT BARU ===
            ],
          ),
        ),
      ),
    );
  }

  // Custom widget for the dashboard buttons
  Widget _dashboardItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}