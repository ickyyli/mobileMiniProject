import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ActivityTimelinePage extends StatelessWidget {
  const ActivityTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Activity Proof"),
        backgroundColor: Colors.deepPurple[50],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Menapis aktiviti berdasarkan studentId (UID parent/anak)
        stream: FirebaseFirestore.instance
            .collection('activities')
            .where('studentId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No activities recorded for today yet."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var activity = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              
              // Format masa dari Timestamp Firestore
              DateTime date = (activity['timestamp'] as Timestamp).toDate();
              String formattedTime = DateFormat('hh:mm a').format(date);

              return _buildActivityCard(
                context,
                time: formattedTime,
                title: activity['title'] ?? 'Activity',
                description: activity['description'] ?? '',
                imageUrl: activity['imageUrl'], // URL gambar dari cikgu
                type: activity['type'] ?? 'general',
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
    required String type
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bahagian Gambar (Proof)
          if (imageUrl != null && imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[800], height: 1.4),
                ),
                const SizedBox(height: 10),
                Chip(
                  label: Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: _getTypeColor(type),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'meal': return Colors.orange;
      case 'nap': return Colors.blue;
      case 'learning': return Colors.green;
      default: return Colors.deepPurple;
    }
  }
}