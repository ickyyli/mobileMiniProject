import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _paymentNotif = true;
  bool _activityNotif = true;
  bool _attendanceNotif = true;
  bool _loading = true;

  final _doc = FirebaseFirestore.instance
      .collection('settings')
      .doc(FirebaseAuth.instance.currentUser?.uid ?? 'admin');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await _doc.get();
      if (snap.exists) {
        final d = snap.data()!;
        setState(() {
          _paymentNotif = d['paymentNotif'] ?? true;
          _activityNotif = d['activityNotif'] ?? true;
          _attendanceNotif = d['attendanceNotif'] ?? true;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    await _doc.set({
      'paymentNotif': _paymentNotif,
      'activityNotif': _activityNotif,
      'attendanceNotif': _attendanceNotif,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Payment Notifications'),
                  subtitle: const Text('Get notified when a parent uploads a receipt'),
                  value: _paymentNotif,
                  activeThumbColor: Colors.teal,
                  onChanged: (v) => setState(() => _paymentNotif = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Activity Updates'),
                  subtitle: const Text('Notify parents when a daily activity is posted'),
                  value: _activityNotif,
                  activeThumbColor: Colors.teal,
                  onChanged: (v) => setState(() => _activityNotif = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Attendance Alerts'),
                  subtitle: const Text('Notify parents when attendance is marked'),
                  value: _attendanceNotif,
                  activeThumbColor: Colors.teal,
                  onChanged: (v) => setState(() => _attendanceNotif = v),
                ),
              ],
            ),
    );
  }
}
