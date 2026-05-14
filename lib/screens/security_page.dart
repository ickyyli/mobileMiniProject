import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Change Password"),
              subtitle: Text("Send reset link to ${user?.email ?? 'your email'}"),
              leading: const Icon(Icons.lock_reset),
              onTap: () async {
                if (user?.email != null) {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset link has been sent!')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}