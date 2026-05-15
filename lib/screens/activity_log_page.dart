import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Already in your pubspec!
import 'package:image_picker/image_picker.dart'; // Already in your pubspec!
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

  // Image State
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Likert Scale State
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

    try {
      String imageUrl = "";

      // 1. Try to upload the image
      if (_selectedImage != null) {
        try {
          String fileName =
              'activity_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('daily_activities')
              .child(fileName);

          // Use putFile and wait for completion
          TaskSnapshot snapshot = await ref.putFile(_selectedImage!);
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (imageError) {
          debugPrint(
              "Image upload failed but continuing with text: $imageError");
          // We don't stop the whole function, just proceed without the image URL
        }
      }

      // 2. Save everything to Firestore
      await FirebaseFirestore.instance.collection('activities').add({
        'student_id': widget.studentId,
        'student_name': widget.studentName,
        'activity_details': _activityController.text,
        'emotion_rating': _selectedEmotion,
        'image_url': imageUrl,
        'date': DateTime.now().toIso8601String(),
        'teacher_name': 'Teacher Aisyah',
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error saving: $e");
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
              // Emotion Section
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

              // Image Section
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
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
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
                          child:
                              Image.file(_selectedImage!, fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 25),

              // Activity Details
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
