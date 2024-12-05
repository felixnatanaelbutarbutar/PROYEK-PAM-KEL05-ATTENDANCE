import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:proyek_pam_kel5/pages/mahasiswa/detail_pengumuman_mahasiswa.dart'; // Import intl

class ListPengumumanPageMahasiswa extends StatelessWidget {
  final String classId; // ID kelas untuk menampilkan pengumuman

  const ListPengumumanPageMahasiswa({Key? key, required this.classId})
      : super(key: key);

  String _formatDate(Timestamp timestamp) {
    // Format tanggal dengan intl
    final DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: Text(
          'Pengumuman',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('pengumuman')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final pengumumanDocs = snapshot.data!.docs;

          if (pengumumanDocs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada pengumuman.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: pengumumanDocs.length,
            itemBuilder: (context, index) {
              final pengumuman = pengumumanDocs[index];
              final data = pengumuman.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  data['title'] ?? 'Tanpa Judul',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  _formatDate(data['timestamp'] as Timestamp), // Format tanggal
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPengumumanMahasiswaPage(
                        classId: classId,
                        pengumumanId: pengumuman.id,
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
