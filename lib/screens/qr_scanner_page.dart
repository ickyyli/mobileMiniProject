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

  void _processAttendance(String studentId) async {
    if (isScanCompleted) return;
    setState(() => isScanCompleted = true);

    try {
      // 1. Update the student's attendance in Firestore
      await FirebaseFirestore.instance.collection('attendance').add({
        'studentId': studentId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Present',
        'markedBy': 'Teacher', 
      });

      // 2. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked for Student ID: $studentId')),
        );
        Navigator.pop(context); // Go back to dashboard after scan
      }
    } catch (e) {
      print("Error marking attendance: $e");
      setState(() => isScanCompleted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Student QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _processAttendance(barcode.rawValue!);
            }
          }
        },
      ),
    );
  }
}