import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:proyek_pam_kel5/pages/mahasiswa/aan.dart';
import 'package:proyek_pam_kel5/pages/mahasiswa/detail_pertemuan_mahasiswa.dart';
import 'package:proyek_pam_kel5/pages/mahasiswa/list_pengumuman_mahasiswa.dart';

class ClassDetailPage extends StatelessWidget {
  final String classId;

  const ClassDetailPage({Key? key, required this.classId}) : super(key: key);

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
  String _formatDate(dynamic rawDate) {
    try {
      if (rawDate is Timestamp) {
        final date = rawDate.toDate();
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
          'Detail Kelas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.announcement, color: Colors.white),
            tooltip: 'Daftar Pengumuman',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListPengumumanPageMahasiswa(classId: classId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Kelas tidak ditemukan.'));
          }

          final classData = snapshot.data!.data() as Map<String, dynamic>;
          final className = classData['className'] ?? 'Unknown Class';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.indigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      className,
                      style: GoogleFonts.oswald(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Daftar Pertemuan
                Expanded(
                  child: DaftarPertemuanPage(classId: classId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DaftarPertemuanPage extends StatelessWidget {
  final String classId;

  const DaftarPertemuanPage({Key? key, required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('pertemuan')
          .orderBy('tanggal', descending: true)
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
            final rawDate = data['tanggal'];
            final attendanceDetails =
                (data['attendance'] as Map<String, dynamic>? ?? {}).map(
              (key, value) => MapEntry(key, value.toString()),
            );
            final hadirCount = attendanceDetails.values
                .where((status) => status == 'Hadir')
                .length;
            final tidakHadirCount = attendanceDetails.values
                .where((status) => status != 'Hadir')
                .length;

            return Card(
              elevation: 42,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.event, color: Colors.white),
                ),
                title: Text(
                  data['judul'] ?? 'Pertemuan',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Hadir: $hadirCount, Tidak Hadir: $tidakHadirCount\n${DateFormat('EEEE, dd MMMM yyyy').format(rawDate.toDate())}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPertemuanMahasiswa(
                          pertemuanId: pertemuan.id,
                          classId: classId,
                        ),
                      ),
                    );
                  },
                  child: Text('Detail', style: TextStyle(color: Colors.blue)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
