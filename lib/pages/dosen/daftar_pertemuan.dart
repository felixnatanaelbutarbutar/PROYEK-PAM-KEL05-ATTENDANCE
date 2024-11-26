import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal
import 'detail_pertemuan.dart';

class DaftarPertemuanPage extends StatelessWidget {
  final String classId;

  const DaftarPertemuanPage({Key? key, required this.classId}) : super(key: key);

  // Fungsi untuk menghitung jumlah mahasiswa hadir
  int _calculateHadir(Map<String, String> attendanceDetails) {
    return attendanceDetails.values.where((status) => status == 'Hadir').length;
  }

  // Fungsi untuk menghitung jumlah mahasiswa tidak hadir
  int _calculateTidakHadir(Map<String, String> attendanceDetails) {
    return attendanceDetails.values.where((status) => status != 'Hadir').length;
  }

  // Fungsi untuk memformat tanggal
  String _formatDate(String? rawDate) {
    if (rawDate == null) return "Tanggal tidak tersedia";
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date); // Format dalam Bahasa Indonesia
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

          return ListView.builder(
            itemCount: pertemuanDocs.length,
            itemBuilder: (context, index) {
              final pertemuan = pertemuanDocs[index];
              final data = pertemuan.data() as Map<String, dynamic>;

              // Ambil data attendance
              final attendanceDetails =
                  (data['attendanceDetails'] as Map<String, dynamic>?)
                          ?.map((key, value) => MapEntry(key, value.toString())) ??
                      {};

              // Hitung hadir dan tidak hadir
              final hadirCount = _calculateHadir(attendanceDetails);
              final tidakHadirCount = _calculateTidakHadir(attendanceDetails);

              // Format tanggal
              final formattedDate = _formatDate(data['tanggal']);

              return ListTile(
                title: Text(
                  '${data['judul'] ?? 'Pertemuan'}: $formattedDate',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
      ),
    );
  }
}
