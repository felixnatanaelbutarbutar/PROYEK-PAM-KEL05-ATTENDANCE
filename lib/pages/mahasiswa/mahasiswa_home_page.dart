import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        SnackBar(content: Text('Absensi berhasil diunggah')),
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
        title: Text('Dashboard Mahasiswa'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
            return Center(child: CircularProgressIndicator());
          }

          final classes = snapshot.data!.docs;
          if (classes.isEmpty) {
            return Center(
              child: Text('Tidak ada kelas yang terdaftar',
                  style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    classData['className'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Klik ikon kamera untuk absensi'),
                  trailing: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: () => _uploadAttendance(context, classData.id),
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
