import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:proyek_pam_kel5/pages/mahasiswa/profil_page_mahasiswa.dart';
import 'class_detail_page.dart';

class MahasiswaHomePage extends StatelessWidget {
  final String mahasiswaId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _uploadAttendance(BuildContext context, String classId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final storageRef = FirebaseStorage.instance
          .ref('attendance/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(File(image.path));
      final photoUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('attendance').add({
        'classId': classId,
        'studentId': mahasiswaId,
        'photoUrl': photoUrl,
        'timestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Absensi berhasil diunggah'),
          backgroundColor: Colors.greenAccent[700],
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(mahasiswaId: mahasiswaId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('students', arrayContains: mahasiswaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = snapshot.data!.docs;
          if (classes.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada kelas yang terdaftar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              return Card(
                elevation: 8,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClassDetailPage(classId: classData.id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            classData['className'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classData['className'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Klik untuk melihat detail kelas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Color(0xFF6A1B9A)),
                        onPressed: () =>
                            _uploadAttendance(context, classData.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
