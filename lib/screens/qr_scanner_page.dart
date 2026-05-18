import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isScanCompleted = false;
  final MobileScannerController controller = MobileScannerController();

  
  Future<void> _sendNotificationToParent(String shortStudentId, String status) async {
    try {
      
      final parentQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('student_id', isEqualTo: shortStudentId)
          .get();

      if (parentQuery.docs.isNotEmpty) {
        for (var doc in parentQuery.docs) {
          final userData = doc.data();
          
          if (userData['role'] == 'parent') {
            String? parentToken = userData['fcmToken'];
            String studentName = userData['student_name'] ?? "Arissa";
            
            if (parentToken != null && parentToken.isNotEmpty) {
              final now = DateTime.now();
              final timeString = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

              await FirebaseFirestore.instance.collection('notifications').add({
                'toToken': parentToken,
                'studentId': shortStudentId,
                'title': 'Kehadiran KindiSync',
                'body': 'My Child, $studentName, successfully $status at $timeString.',
                'status': status,
                'createdAt': FieldValue.serverTimestamp(),
              });
              debugPrint("Notification sent to parent with token: $parentToken");
            } else {
              debugPrint("Access denied: Parent does not have a valid FCM token.");
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to send notification: $e");
    }
  }

  void _processAttendance(String shortStudentId) async {
    if (isScanCompleted) return;
    setState(() => isScanCompleted = true);

    try {
      final attendanceRef = FirebaseFirestore.instance.collection('attendance');
      
      
      final querySnapshot = await attendanceRef
          .where('studentId', isEqualTo: shortStudentId)
          .get();

    
      DateTime now = DateTime.now();
      DateTime todayStart = DateTime(now.year, now.month, now.day);
      DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      int todayLogsCount = 0;

      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final Timestamp? ts = data['timestamp'];
        if (ts != null) {
          DateTime logTime = ts.toDate();
          if (logTime.isAfter(todayStart) && logTime.isBefore(todayEnd)) {
            todayLogsCount++;
          }
        }
      }

      
      String newStatus = "Check-In";
      if (todayLogsCount % 2 != 0) {
        newStatus = "Check-Out";
      }

      
      await attendanceRef.add({
        'studentId': shortStudentId, 
        'timestamp': FieldValue.serverTimestamp(),
        'status': newStatus,
        'markedBy': 'Teacher',
      });

      await _sendNotificationToParent(shortStudentId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully $newStatus for ID: $shortStudentId'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ralat: $e"), backgroundColor: Colors.red),
        );
        setState(() => isScanCompleted = false);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student QR'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !isScanCompleted) {
                  _processAttendance(barcode.rawValue!);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}