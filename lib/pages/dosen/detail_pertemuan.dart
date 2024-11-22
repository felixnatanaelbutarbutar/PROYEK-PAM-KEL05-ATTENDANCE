import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPertemuanPage extends StatelessWidget {
  final String pertemuanId;
  final String classId;

  const DetailPertemuanPage({
    Key? key,
    required this.pertemuanId,
    required this.classId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pertemuan'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('pertemuan')
            .doc(pertemuanId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final pertemuanData = snapshot.data!.data() as Map<String, dynamic>?;
          final attendance = pertemuanData?['attendance'] as Map<String, dynamic>? ?? {};

          return ListView(
            children: [
              ListTile(
                title: Text('Judul Pertemuan: ${pertemuanData?['title'] ?? ''}'),
                subtitle: Text('Tanggal: ${pertemuanData?['date'] ?? ''}'),
              ),
              Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: attendance.length,
                itemBuilder: (context, index) {
                  final studentId = attendance.keys.elementAt(index);
                  final status = attendance[studentId];
                  return ListTile(
                    title: Text('Mahasiswa ID: $studentId'),
                    subtitle: Text('Status Kehadiran: $status'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
