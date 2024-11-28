import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'detail_pertemuan.dart';

class DaftarPertemuanPage extends StatelessWidget {
  final String classId;

  const DaftarPertemuanPage({Key? key, required this.classId})
      : super(key: key);

  // Fungsi untuk menghitung total kehadiran
  int _calculateHadir(
      Map<String, String> attendanceDetails, int totalStudents) {
    final tidakHadirCount =
        attendanceDetails.values.where((status) => status != 'Hadir').length;
    return totalStudents - tidakHadirCount;
  }

  // Fungsi untuk menghitung total tidak hadir
  int _calculateTidakHadir(Map<String, String> attendanceDetails) {
    return attendanceDetails.values.where((status) => status != 'Hadir').length;
  }

  // Fungsi untuk memformat tanggal dengan penanganan Firestore Timestamp
  String _formatDate(dynamic rawDate) {
    try {
      if (rawDate is Timestamp) {
        final date = rawDate.toDate(); // Konversi dari Timestamp ke DateTime
        return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
      } else if (rawDate is DateTime) {
        return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(rawDate);
      } else {
        return "Tanggal tidak valid";
      }
    } catch (e) {
      return "Tanggal tidak valid";
    }
  }

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
            return const Center(child: CircularProgressIndicator());
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

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('classes')
                .doc(classId)
                .snapshots(),
            builder: (context, classSnapshot) {
              if (!classSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final classData =
                  classSnapshot.data!.data() as Map<String, dynamic>;
              final totalStudents =
                  (classData['students'] as List<dynamic>).length;

              return ListView.builder(
                itemCount: pertemuanDocs.length,
                itemBuilder: (context, index) {
                  final pertemuan = pertemuanDocs[index];
                  final data = pertemuan.data() as Map<String, dynamic>;

                  // Konversi attendanceDetails menjadi Map<String, String>
                  final attendanceDetails = (data['attendanceDetails']
                          as Map<String, dynamic>? ??
                      {}).map(
                    (key, value) => MapEntry(key, value.toString()),
                  );

                  // Ambil tanggal dari attendanceDetails
                  final rawDate = attendanceDetails['tanggal'];

                  final hadirCount =
                      _calculateHadir(attendanceDetails, totalStudents);
                  final tidakHadirCount =
                      _calculateTidakHadir(attendanceDetails);

                  final formattedDate = _formatDate(rawDate);

                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['judul'] ?? 'Pertemuan'}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Hadir: $hadirCount, Tidak Hadir: $tidakHadirCount',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
          );
        },
      ),
    );
  }
}
