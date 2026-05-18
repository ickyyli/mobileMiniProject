import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ActivityTimelinePage extends StatelessWidget {
  const ActivityTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? parentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Daily Activity Proof",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[50],
        elevation: 0,
      ),
      body: parentUid == null 
          ? const Center(child: Text("Please log in to view activities."))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(parentUid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text("Parent profile not found."));
                }

                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                String myChildId = userData['student_id'] ?? '';

                if (myChildId.isEmpty) {
                  return const Center(child: Text("No student linked to this account."));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activities')
                      .where('student_id', isEqualTo: myChildId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No activities recorded for today yet."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var activity = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        
                        DateTime date = (activity['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                        String formattedTime = DateFormat('hh:mm a').format(date);

                        return _buildActivityCard(
                          context,
                          time: formattedTime,
                          title: "${activity['emotion_emoji'] ?? '😊'} ${activity['emotion_label'] ?? 'Activity'}",
                          description: activity['activity_details'] ?? '',
                          imageUrl: activity['image_url'], // Membaca field 'image_url' dari Firestore
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildActivityCard(BuildContext context, {
    required String time, 
    required String title, 
    required String description, 
    String? imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142))
                ),
                Text(
                  time, 
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.w600)
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              description, 
              style: const TextStyle(color: Colors.black54, fontSize: 14)
            ),

            
            if (imageUrl != null && imageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                        SizedBox(height: 4),
                        Text("Gagal memuatkan imej", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}