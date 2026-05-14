import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'child_profile_page.dart';
import 'notifications_page.dart';
import 'payment_page.dart';
import 'activity_timeline_page.dart';
import 'pickup_registry_page.dart';
import 'parent_settings_page.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Parent Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Main Menu", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))
            ),
            const SizedBox(height: 16),
            
            // Grid untuk semua menu - Diubah menjadi memanjang ke tepi
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, // Kekal 2 kolum tapi nisbah diubah
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Nisbah 2.0 bermaksud lebar adalah 2x ganda ketinggian (kotak jadi nipis & memanjang)
              childAspectRatio: 2.1, 
              children: [
                _buildWideMenuCard(context, "Child Profile", Icons.face_rounded, Colors.blue, const ChildProfilePage()),
                _buildWideMenuCard(context, "Activity", Icons.timeline_rounded, Colors.orange, const ActivityTimelinePage()),
                _buildWideMenuCard(context, "Payments", Icons.account_balance_wallet_rounded, Colors.green, const PaymentPage()),
                _buildWideMenuCard(context, "Pickup", Icons.assignment_ind_rounded, Colors.redAccent, const PickupRegistryPage()),
                _buildWideMenuCard(context, "Attendance", Icons.calendar_today_rounded, Colors.purple, const Placeholder()), 
                _buildWideMenuCard(context, "Settings", Icons.settings_rounded, Colors.grey, const ParentSettingsPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget baru untuk kotak yang lebar dan pendek (Horizontal Style)
  Widget _buildWideMenuCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), 
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row( // Menggunakan Row supaya ikon & teks duduk sebelah menyebelah
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13,
                  color: Color(0xFF2D3142)
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}