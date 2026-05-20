import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final Map<String, bool> _checked = {};
  bool _saving = false;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _saveAttendance(List<_Student> students) async {
    setState(() => _saving = true);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final col = FirebaseFirestore.instance.collection('attendance');
      int saved = 0;

      for (final s in students) {
        final isPresent = _checked[s.studentId] ?? false;
        final docRef = col.doc('${s.studentId}_$_todayKey');

        if (isPresent) {
          batch.set(docRef, {
            'studentId': s.studentId,
            'status': 'Present',
            'timestamp': FieldValue.serverTimestamp(),
            'date': _todayKey,
          });
          saved++;
        } else {
          batch.delete(docRef);
        }
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved — $saved student(s) marked Present.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prettyDate = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(prettyDate,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'parent')
                  .snapshots(),
              builder: (context, studentsSnap) {
                if (studentsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!studentsSnap.hasData || studentsSnap.data!.docs.isEmpty) {
                  return const Center(child: Text('No students registered.'));
                }

                final students = studentsSnap.data!.docs
                    .map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return _Student(
                        studentId: (data['student_id'] ?? '').toString(),
                        name: (data['student_name'] ?? 'Unknown').toString(),
                        className: (data['className'] ?? '-').toString(),
                      );
                    })
                    .where((s) => s.studentId.isNotEmpty)
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('date', isEqualTo: _todayKey)
                      .snapshots(),
                  builder: (context, attSnap) {
                    if (attSnap.connectionState == ConnectionState.waiting &&
                        !attSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final presentToday = <String>{};
                    if (attSnap.hasData) {
                      for (final d in attSnap.data!.docs) {
                        final data = d.data() as Map<String, dynamic>;
                        final sid = (data['studentId'] ?? '').toString();
                        if (sid.isNotEmpty) presentToday.add(sid);
                      }
                    }

                    for (final s in students) {
                      _checked.putIfAbsent(
                          s.studentId, () => presentToday.contains(s.studentId));
                    }

                    return _buildList(students);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : () => _saveCurrentList(),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_saving ? 'Saving...' : 'Save Attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentList() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'parent')
        .get();

    final students = snap.docs
        .map((d) {
          final data = d.data();
          return _Student(
            studentId: (data['student_id'] ?? '').toString(),
            name: (data['student_name'] ?? 'Unknown').toString(),
            className: (data['className'] ?? '-').toString(),
          );
        })
        .where((s) => s.studentId.isNotEmpty)
        .toList();

    await _saveAttendance(students);
  }

  Widget _buildList(List<_Student> students) {
    final presentCount = students.where((s) => _checked[s.studentId] == true).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${students.length} student(s)',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                'Present: $presentCount',
                style: const TextStyle(
                    color: Colors.teal, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final s = students[index];
              final isChecked = _checked[s.studentId] ?? false;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CheckboxListTile(
                  value: isChecked,
                  onChanged: (v) => setState(
                      () => _checked[s.studentId] = v ?? false),
                  title: Text(s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Class: ${s.className}   •   ID: ${s.studentId}'),
                  secondary: CircleAvatar(
                    backgroundColor:
                        isChecked ? Colors.green.shade100 : Colors.grey.shade200,
                    child: Icon(
                      isChecked ? Icons.check_circle : Icons.person,
                      color: isChecked ? Colors.green : Colors.grey,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: Colors.teal,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Student {
  final String studentId;
  final String name;
  final String className;
  _Student({required this.studentId, required this.name, required this.className});
}
