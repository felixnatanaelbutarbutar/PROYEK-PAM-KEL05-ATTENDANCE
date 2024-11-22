import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassDetailPage extends StatelessWidget {
  final String classId;

  const ClassDetailPage({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Kelas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('classes').doc(classId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Kelas tidak ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final classData = snapshot.data!;
          final className = classData['className'] ?? 'Unknown Class';
          final students = classData['students'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Kelas: $className',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Daftar Mahasiswa:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(students[index])
                            .get(),
                        builder: (context, studentSnapshot) {
                          if (!studentSnapshot.hasData ||
                              !studentSnapshot.data!.exists) {
                            return ListTile(
                              title: Text('Mahasiswa tidak ditemukan'),
                            );
                          }

                          final studentData = studentSnapshot.data!;
                          return ListTile(
                            title: Text(studentData['name'] ?? 'Nama tidak tersedia'),
                            subtitle: Text('NIM: ${studentData['nim'] ?? 'N/A'}'),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueGrey[200],
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
