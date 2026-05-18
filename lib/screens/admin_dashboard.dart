import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'register_student_page.dart';
import 'student_qr_page.dart';
import 'broadcast_page.dart';
import 'settings_menu_page.dart';
import 'admin_payment_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text(
          "KindiSync Admin",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3142),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("Logout Error: $e");
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Hi, Farah Waheeda! 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'parent')
                        .snapshots(),

                    builder: (context, snapshot) {

                      // DEBUG
                      debugPrint("========== STUDENT COUNTER ==========");
                      debugPrint(
                        "Connection: ${snapshot.connectionState}",
                      );
                      debugPrint(
                        "Has Data: ${snapshot.hasData}",
                      );
                      debugPrint(
                        "Docs Length: ${snapshot.data?.docs.length}",
                      );
                      debugPrint(
                        "Error: ${snapshot.error}",
                      );

                      // LOADING
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return _buildStatItem("...", "Students");
                      }

                      // ERROR
                      if (snapshot.hasError) {
                        return _buildStatItem("0", "Students");
                      }

                      // NO DATA
                      if (!snapshot.hasData) {
                        return _buildStatItem("0", "Students");
                      }

                      // TOTAL
                      int totalStudents =
                          snapshot.data!.docs.length;

                      return _buildStatItem(
                        totalStudents.toString(),
                        "Students",
                      );
                    },
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('activities')
                        .snapshots(),

                    builder: (context, snapshot) {

                      String count = "0";

                      if (snapshot.hasData) {
                        count = snapshot.data!.docs.length.toString();
                      }

                      return _buildStatItem(
                        count,
                        "Activities",
                      );
                    },
                  ),


                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('payment')
                        .snapshots(),

                    builder: (context, snapshot) {

                      String count = "0";

                      if (snapshot.hasData) {

                        final dueDocs =
                            snapshot.data!.docs.where((doc) {

                          String status =
                              (doc['status'] ?? '')
                                  .toString()
                                  .toLowerCase();

                          return status == 'pending' ||
                              status == 'overdue';

                        }).toList();

                        count = dueDocs.length.toString();
                      }

                      return _buildStatItem(
                        count,
                        "Due",
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Management Overview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),

            const SizedBox(height: 12),


            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,

              children: [

                _buildActionCard(
                  context,
                  "Register",
                  Icons.person_add_alt_1_rounded,
                  const Color(0xFF6C63FF),

                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RegisterStudentPage(),
                    ),
                  ),
                ),

                _buildActionCard(
                  context,
                  "Attendance",
                  Icons.qr_code_rounded,
                  Colors.blue,

                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const StudentQrPage(),
                    ),
                  ),
                ),

                _buildActionCard(
                  context,
                  "Safety",
                  Icons.security_rounded,
                  Colors.redAccent,
                  () {},
                ),

                _buildActionCard(
                  context,
                  "Messages",
                  Icons.chat_bubble_rounded,
                  Colors.orange,

                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BroadcastPage(),
                      ),
                    );
                  },
                ),

                _buildActionCard(
                  context,
                  "Payments",
                  Icons.payment_rounded,
                  Colors.green,

                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminPaymentPage(),
                      ),
                    );
                  },
                ),

                _buildActionCard(
                  context,
                  "Settings",
                  Icons.settings_rounded,
                  Colors.grey,

                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SettingsMenuPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15),
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              backgroundColor:
                  color.withValues(alpha: 0.1),

              radius: 26,

              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ),
    );
  }
}