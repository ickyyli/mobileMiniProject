import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String get parentEmail => FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple[100],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ambil data dari broadcasts dahulu secara terus
        stream: FirebaseFirestore.instance
            .collection('broadcasts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, broadcastSnapshot) {
          if (broadcastSnapshot.hasError) return const Center(child: Text("Error loading notifications"));
          if (broadcastSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('parentEmail', isEqualTo: parentEmail)
                .snapshots(),
            builder: (context, personalSnapshot) {
              if (personalSnapshot.hasError) return const Center(child: Text("Error loading personal alerts"));

              // Gabungkan kedua-dua data dokumen jika ada
              List<QueryDocumentSnapshot> combinedList = [];
              
              if (broadcastSnapshot.hasData) {
                combinedList.addAll(broadcastSnapshot.data!.docs);
              }
              if (personalSnapshot.hasData) {
                combinedList.addAll(personalSnapshot.data!.docs);
              }

            
              combinedList.sort((a, b) {
                var dataA = a.data() as Map<String, dynamic>;
                var dataB = b.data() as Map<String, dynamic>;
                
                Timestamp tA = dataA['timestamp'] ?? Timestamp.now();
                Timestamp tB = dataB['timestamp'] ?? Timestamp.now();
                return tB.compareTo(tA);
              });

              if (combinedList.isEmpty) {
                return const Center(child: Text("No notifications available at this time."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: combinedList.length,
                itemBuilder: (context, index) {
                  final doc = combinedList[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
               
                  final bool isPayment = doc.reference.parent.id == 'notifications';
                  
                  String title = data['title'] ?? 'No Title';
                  String message = isPayment ? (data['body'] ?? '') : (data['message'] ?? '');
                  
                  DateTime date = DateTime.now();
                  if (data['timestamp'] != null) {
                    date = (data['timestamp'] as Timestamp).toDate();
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: isPayment 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.orangeAccent.withValues(alpha: 0.1),
                        radius: 24,
                        child: Icon(
                          isPayment ? Icons.payment_rounded : Icons.campaign_rounded, 
                          color: isPayment ? Colors.green : Colors.orangeAccent,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3142))
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            message, 
                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)
                          ),
                          const SizedBox(height: 10),
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(date),
                            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}