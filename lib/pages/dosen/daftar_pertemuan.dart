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

  // Fungsi untuk memformat tanggal

  // Fungsi untuk memformat tanggal
  String _formatDate(dynamic rawDate) {
    if (rawDate is Timestamp) {
      final date = rawDate.toDate();
      return DateFormat('dd MMMM yyyy').format(date);
    }
    return "Tanggal tidak valid";
  }

  // Fungsi untuk menghapus pertemuan
  Future<void> _deletePertemuan(
      BuildContext context, String pertemuanId) async {
    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('pertemuan')
          .doc(pertemuanId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pertemuan berhasil dihapus.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus pertemuan: $e',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
            color: Colors.white,
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
            .orderBy('tanggal',
                descending: true) // Mengurutkan berdasarkan tanggal
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

              final attendanceDetails =
                  (data['attendance'] as Map<String, dynamic>? ?? {}).map(
                (key, value) => MapEntry(key, value.toString()),
              );
              // Ambil dan format tanggal
              final rawDate = data['tanggal'];
              final formattedDate = _formatDate(rawDate);
              final hadirCount = _calculateHadir(attendanceDetails,
                  (data['students'] as List<dynamic>? ?? []).length);
              final tidakHadirCount = _calculateTidakHadir(attendanceDetails);

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi Hapus'),
                            content: const Text(
                                'Apakah Anda yakin ingin menghapus pertemuan ini?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          _deletePertemuan(context, pertemuan.id);
                        }
                      },
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
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
