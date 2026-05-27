import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _processing = false;
  final MobileScannerController _controller = MobileScannerController();

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _processAttendance(String studentId) async {
    if (_processing) return;
    setState(() => _processing = true);
    await _controller.stop();

    try {
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('student_id', isEqualTo: studentId)
          .limit(1)
          .get();

      if (usersSnap.docs.isEmpty) {
        _showMessage('No student found for ID: $studentId', Colors.red);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _processing = false);
          await _controller.start();
        }
        return;
      }

      final studentName =
          (usersSnap.docs.first.data()['student_name'] ?? 'Unknown').toString();

      await FirebaseFirestore.instance
          .collection('attendance')
          .doc('${studentId}_$_todayKey')
          .set({
        'studentId': studentId,
        'status': 'Present',
        'timestamp': FieldValue.serverTimestamp(),
        'date': _todayKey,
        'markedBy': 'Teacher (QR)',
      });

      _showMessage('Attendance marked: $studentName', Colors.green);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Error: $e', Colors.red);
      if (mounted) {
        setState(() => _processing = false);
        await _controller.start();
      }
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student QR'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final value = barcode.rawValue;
                if (value != null && value.isNotEmpty) {
                  _processAttendance(value);
                  break;
                }
              }
            },
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Align student QR within the frame',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
