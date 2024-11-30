import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailMahasiswaPage extends StatelessWidget {
  final String studentId;

  const DetailMahasiswaPage({Key? key, required this.studentId}) : super(key: key);

  // Fungsi untuk memformat tanggal
  String _formatDate(dynamic rawDate) {
    if (rawDate is Timestamp) {
      final date = rawDate.toDate();
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
    return "Tanggal tidak valid";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Mahasiswa',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }

          final studentData = snapshot.data!.data() as Map<String, dynamic>;
          final name = studentData['name'] ?? 'N/A';
          final nim = studentData['nim'] ?? 'N/A';
          final classId = studentData['kelas'] ?? 'N/A';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama: $name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('NIM: $nim', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Kelas: $classId', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text(
                    'Keterangan Absensi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .doc(classId)
                        .collection('pertemuan')
                        .snapshots(),
                    builder: (context, pertemuanSnapshot) {
                      if (!pertemuanSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (pertemuanSnapshot.hasError) {
                        return const Text('Gagal memuat data absensi.');
                      }

                      final pertemuanDocs = pertemuanSnapshot.data!.docs;

                      if (pertemuanDocs.isEmpty) {
                        return const Text('Tidak ada catatan absensi.');
                      }

                      int totalHadir = 0;
                      int totalPertemuan = 0;

                      final absensiWidgets = pertemuanDocs.map((pertemuan) {
                        final data = pertemuan.data() as Map<String, dynamic>;
                        final attendance = data['attendance'] as Map<String, dynamic>;
                        final status = attendance[nim] ?? 'Tidak Hadir';
                        final tanggal = _formatDate(data['tanggal']);
                        final judul = data['judul'] ?? 'Pertemuan';

                        if (status == 'Hadir') totalHadir++;
                        totalPertemuan++;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Judul: $judul\nTanggal: $tanggal\nStatus: $status',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList();

                      final attendancePercentage = totalPertemuan > 0
                          ? (totalHadir / totalPertemuan) * 100
                          : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...absensiWidgets,
                          const SizedBox(height: 20),
                          Text('Total Pertemuan: $totalPertemuan', style: const TextStyle(fontSize: 16)),
                          Text('Kehadiran: $totalHadir', style: const TextStyle(fontSize: 16)),
                          Text(
                            'Persentase Kehadiran: ${attendancePercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Status UTS/UAS: ${attendancePercentage >= 75.0 ? 'Layak' : 'Tidak Layak'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: attendancePercentage >= 75.0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
