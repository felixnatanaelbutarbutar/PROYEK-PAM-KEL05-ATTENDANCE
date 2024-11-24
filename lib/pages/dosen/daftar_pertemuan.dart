import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_pertemuan.dart';

class DaftarPertemuanPage extends StatelessWidget {
  final String classId;

  const DaftarPertemuanPage({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Pertemuan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('pertemuan')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final pertemuanDocs = snapshot.data!.docs;

          if (pertemuanDocs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada pertemuan yang dibuat.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: pertemuanDocs.length,
            itemBuilder: (context, index) {
              final pertemuan = pertemuanDocs[index];
              final data = pertemuan.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  'Pertemuan: ${data['tanggal'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Hadir: ${data['hadir'] ?? 0}, Absen: ${data['absen'] ?? 0}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPertemuanPage(
                        pertemuanId: pertemuan.id,
                        classId: classId,
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
