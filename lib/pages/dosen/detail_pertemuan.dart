import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: Text(
          'Detail Pertemuan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('pertemuan')
            .doc(pertemuanId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data pertemuan tidak ditemukan.'));
          }

          final pertemuanData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final attendance =
              pertemuanData['attendance'] as Map<String, dynamic>? ?? {};
          final students = pertemuanData['students'] as List<dynamic>? ?? [];

          // Membuat daftar mahasiswa berdasarkan students dan attendance
          List<Map<String, dynamic>> studentList = students.map((student) {
            final studentNim = student['nim'] ?? 'N/A';
            final studentName = student['name'] ?? 'Unknown';
            final status = attendance[studentNim] ?? 'Tidak Hadir';
            return {
              'nim': studentNim,
              'name': studentName,
              'status': status,
            };
          }).toList();

          // Mengurutkan daftar mahasiswa berdasarkan NIM
          studentList.sort((a, b) => a['nim'].compareTo(b['nim']));

          // Format tanggal
          String formattedDate = '-';
          if (pertemuanData['tanggal'] != null) {
            final timestamp = pertemuanData['tanggal'] as Timestamp;
            formattedDate =
                DateFormat('dd MMMM yyyy').format(timestamp.toDate());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Judul dan Tanggal Pertemuan
                Container(
                  width: double
                      .infinity, // Membuat Card selebar mungkin sesuai parent-nya
                  child: Card(
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          12.0), // Tambahkan padding agar lebih proporsional
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Judul Pertemuan',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pertemuanData['judul'] ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tanggal',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tabel Daftar Kehadiran
                Text(
                  'Daftar Kehadiran',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      dataTextStyle: const TextStyle(fontSize: 14),
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.blueGrey[900]!,
                      ),
                      columns: const [
                        DataColumn(label: Text('NIM')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Status Kehadiran')),
                      ],
                      rows: studentList.map((student) {
                        return DataRow(
                          cells: [
                            DataCell(Text(student['nim'])),
                            DataCell(Text(student['name'])),
                            DataCell(
                              Text(
                                student['status'],
                                style: TextStyle(
                                  color: student['status'] == 'Hadir'
                                      ? Colors.green
                                      : student['status'] == 'Sakit'
                                          ? Colors.orange
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
