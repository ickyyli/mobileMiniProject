import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; 
import 'register_student_page.dart';
// Import StudentQrPage untuk senarai QR
import 'student_qr_page.dart'; 
import 'broadcast_page.dart'; 
import 'settings_menu_page.dart'; 

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("KindiSync Admin", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    MaterialPageRoute(builder: (context) => const LoginPage()),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
            const SizedBox(height: 16),
            
            // Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  String studentCount = "0";
                  if (snapshot.hasData) {
                    studentCount = snapshot.data!.docs
                        .where((doc) => doc['role'] == 'parent')
                        .length
                        .toString();
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(studentCount, "Students"),
                      _buildStatItem("0", "Activities"),
                      _buildStatItem("0", "Due"),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Management Overview",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
            const SizedBox(height: 12),

            // Grid Layout
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
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterStudentPage())),
                ),
                
                // PERUBAHAN DI SINI: Attendance kini pergi ke StudentQrPage
                _buildActionCard(
                  context, 
                  "Attendance", 
                  Icons.qr_code_rounded, // Tukar ikon kepada QR supaya lebih jelas
                  Colors.blue, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentQrPage())),
                ),
                
                _buildActionCard(context, "Safety", Icons.security_rounded, Colors.redAccent, () {}),
                
                _buildActionCard(
                  context, 
                  "Messages", 
                  Icons.chat_bubble_rounded, 
                  Colors.orange, 
                  () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const BroadcastPage())
                    );
                  }
                ),
                
                _buildActionCard(context, "Payments", Icons.payment_rounded, Colors.green, () {}),
                
                _buildActionCard(
                  context, 
                  "Settings", 
                  Icons.settings_rounded, 
                  Colors.grey, 
                  () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const SettingsMenuPage())
                    );
                  }
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
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: 26, 
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title, 
              textAlign: TextAlign.center, 
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2D3142)),
            ),
          ],
        ),
      ),
    );
  }
}