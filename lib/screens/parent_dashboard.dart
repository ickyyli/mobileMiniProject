import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import 'child_profile_page.dart';
import 'notifications_page.dart';
import 'payment_page.dart';
import 'activity_timeline_page.dart';
import 'pickup_registry_page.dart';
import 'parent_settings_page.dart';
import 'attendance_page.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: const Text(
          "Parent Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.deepPurple[100],
        elevation: 0,

        actions: [

          // NOTIFICATION BUTTON
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),

          // LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout_rounded),

            onPressed: () async {

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
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // TITLE
            const Text(
              "Main Menu",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),

            const SizedBox(height: 16),

            // MENU GRID
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              // Wide horizontal card
              childAspectRatio: 2.1,

              children: [

                // CHILD PROFILE
                _buildWideMenuCard(
                  context,
                  "Child Profile",
                  Icons.face_rounded,
                  Colors.blue,
                  const ChildProfilePage(),
                ),

                // ACTIVITY
                _buildWideMenuCard(
                  context,
                  "Activity",
                  Icons.timeline_rounded,
                  Colors.orange,
                  const ActivityTimelinePage(),
                ),

                // PAYMENT
                _buildWideMenuCard(
                  context,
                  "Payments",
                  Icons.account_balance_wallet_rounded,
                  Colors.green,
                  const PaymentPage(),
                ),

                // PICKUP
                _buildWideMenuCard(
                  context,
                  "Pickup",
                  Icons.assignment_ind_rounded,
                  Colors.redAccent,
                  const PickupRegistryPage(),
                ),

                // ATTENDANCE FIXED
                _buildWideMenuCard(
                  context,
                  "Attendance",
                  Icons.calendar_today_rounded,
                  Colors.purple,
                  const AttendancePage(),
                ),

                // SETTINGS
                _buildWideMenuCard(
                  context,
                  "Settings",
                  Icons.settings_rounded,
                  Colors.grey,
                  const ParentSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // MENU CARD WIDGET
  // =========================================

  Widget _buildWideMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {

    return InkWell(

      onTap: () {

        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) => destination,
          ),
        );
      },

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
            ),
          ],

          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [

            // ICON BOX
            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            // TITLE
            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF2D3142),
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