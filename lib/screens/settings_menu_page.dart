import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';
import 'security_page.dart';
import 'user_management_page.dart';
import 'notification_settings_page.dart';

class SettingsMenuPage extends StatelessWidget {
  const SettingsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            targetPage: const EditProfilePage(),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Change password & access',
            targetPage: const SecurityPage(),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.group_outlined,
            title: 'User Management',
            subtitle: 'Manage staff and teacher accounts',
            targetPage: const UserManagementPage(),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_none_outlined,
            title: 'Notification',
            subtitle: 'System notification settings',
            targetPage: const NotificationSettingsPage(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Widget targetPage}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
      },
    );
  }
}