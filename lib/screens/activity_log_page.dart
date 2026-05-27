import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ActivityLogPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ActivityLogPage(
      {super.key, required this.studentId, required this.studentName});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final TextEditingController _activityController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  int _selectedEmotion = 3;
  
  final List<Map<String, dynamic>> _emotions = [
    {'emoji': '😢', 'label': 'Sad', 'value': 1},
    {'emoji': '😕', 'label': 'Moody', 'value': 2},
    {'emoji': '😊', 'label': 'Happy', 'value': 3},
    {'emoji': '🌟', 'label': 'Excited', 'value': 4},
    {'emoji': '😴', 'label': 'Tired', 'value': 5},
  ];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, 
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveActivity() async {
    if (_activityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the activity')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String imageUrl = "";

      if (_selectedImage != null) {
        try {
          String fileName = 'activity_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('daily_activities')
              .child(fileName);

          TaskSnapshot snapshot = await ref.putFile(_selectedImage!);
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (imageError) {
          debugPrint("Image upload failed: $imageError");
        }
      }

      // Menyimpan pautan data ke field 'image_url'
      await FirebaseFirestore.instance.collection('activities').add({
        'student_id': widget.studentId,
        'student_name': widget.studentName,
        'activity_details': _activityController.text.trim(),
        'emotion_label': _emotions.firstWhere((e) => e['value'] == _selectedEmotion)['label'],
        'emotion_emoji': _emotions.firstWhere((e) => e['value'] == _selectedEmotion)['emoji'],
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(), 
        'teacher_name': FirebaseAuth.instance.currentUser?.email ?? 'Teacher',
      });

      if (mounted) {
        Navigator.pop(context); 
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update posted successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Error saving: $e");
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save activity: $e')),
      );
    }
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log for ${widget.studentName}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("How was their mood today?",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _emotions.map((emotion) {
                  bool isSelected = _selectedEmotion == emotion['value'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedEmotion = emotion['value']),
                    child: Column(
                      children: [
                        Text(emotion['emoji'],
                            style: TextStyle(fontSize: isSelected ? 40 : 30)),
                        Text(emotion['label'],
                            style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.teal : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              const Text("Add a Photo",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.teal),
                              Text("Tap to take a photo")
                            ])
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 25),
              const Text("Activity Details",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 10),
              TextField(
                controller: _activityController,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: "Enter activity notes...",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Post Update',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}