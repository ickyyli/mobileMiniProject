import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();

    // Get logged in user ID
    currentUserId = FirebaseAuth.instance.currentUser?.uid;

    print("Current UID: $currentUserId");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Attendance"),
          centerTitle: true,

          bottom: const TabBar(
            tabs: [

              // QR TAB
              Tab(
                icon: Icon(Icons.qr_code),
                text: "My QR",
              ),

              // HISTORY TAB
              Tab(
                icon: Icon(Icons.history),
                text: "Logs",
              ),
            ],
          ),
        ),

        body: currentUserId == null

            // USER NOT LOGIN
            ? const Center(
                child: Text(
                  "User not logged in",
                  style: TextStyle(fontSize: 18),
                ),
              )

            // TAB PAGES
            : TabBarView(
                children: [

                  // QR PAGE
                  _buildQRPage(currentUserId!),

                  // LOG PAGE
                  _buildLogsPage(),

                ],
              ),
      ),
    );
  }

  // =====================================
  // QR PAGE
  // =====================================

  Widget _buildQRPage(String uid) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const SizedBox(height: 40),

              const Text(
                "Show this QR to teacher",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // QR CARD
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: QrImageView(
                  data: uid,
                  version: QrVersions.auto,
                  size: 250,

                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Student ID",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SelectableText(
                uid,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================
  // LOGS PAGE
  // =====================================

  Widget _buildLogsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        // SAMPLE LOG 1
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,

              child: const Icon(
                Icons.login,
                color: Colors.white,
              ),
            ),

            title: const Text("Check In"),

            subtitle: const Text(
              "15 May 2026 - 7:30 AM",
            ),
          ),
        ),

        const SizedBox(height: 10),

        // SAMPLE LOG 2
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,

              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),

            title: const Text("Check Out"),

            subtitle: const Text(
              "15 May 2026 - 12:30 PM",
            ),
          ),
        ),

        const SizedBox(height: 10),

        // SAMPLE LOG 3
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,

              child: const Icon(
                Icons.login,
                color: Colors.white,
              ),
            ),

            title: const Text("Check In"),

            subtitle: const Text(
              "14 May 2026 - 7:35 AM",
            ),
          ),
        ),
      ],
    );
  }
}