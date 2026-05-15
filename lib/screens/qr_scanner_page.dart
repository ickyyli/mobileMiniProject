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

  void _processAttendance(String studentId) async {
    if (isScanCompleted) return;
    setState(() => isScanCompleted = true);

    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final attendanceRef = FirebaseFirestore.instance.collection('attendance');
      
      // Mencari status terakhir murid pada hari ini
      final querySnapshot = await attendanceRef
          .where('studentId', isEqualTo: studentId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .get();

      String newStatus = "Check-In";
      
      // Jika sudah ada rekod hari ini, tukar status berdasarkan jumlah rekod
      if (querySnapshot.docs.isNotEmpty) {
        // Logik mudah: Jika jumlah rekod ganjil (1), maksudnya sudah Check-In, jadi sekarang Check-Out
        if (querySnapshot.docs.length % 2 != 0) {
          newStatus = "Check-Out";
        }
      }

      await attendanceRef.add({
        'studentId': studentId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': newStatus,
        'markedBy': 'Teacher',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berjaya $newStatus untuk ID: $studentId'),
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
          // Frame scanner di tengah skrin
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