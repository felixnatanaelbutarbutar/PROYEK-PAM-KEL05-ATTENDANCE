import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailMahasiswaPage extends StatelessWidget {
  final String studentId;

  const DetailMahasiswaPage({Key? key, required this.studentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Mahasiswa'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }

          final studentData = snapshot.data!.data() as Map<String, dynamic>;
          final name = studentData['name'] ?? 'N/A';
          final nim = studentData['nim'] ?? 'N/A';
          final kelas = studentData['kelas'] ?? 'N/A';
          final angkatan = studentData['angkatan'] ?? 'N/A';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama: $name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('NIM: $nim', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Kelas: $kelas', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Angkatan: $angkatan', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text(
                    'Keterangan Absensi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('attendances')
                        .where('classId', isEqualTo: kelas) // Sesuaikan dengan kelas
                        .snapshots(),
                    builder: (context, attendanceSnapshot) {
                      if (!attendanceSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (attendanceSnapshot.hasError) {
                        return Text('Gagal memuat data absensi.');
                      }

                      final attendanceRecords = attendanceSnapshot.data!.docs;

                      // Filter absensi berdasarkan studentId
                      final studentAttendance = attendanceRecords
                          .where((attendance) {
                            final attendanceDetails =
                                attendance['attendanceDetails'] as Map<String, dynamic>?;
                            return attendanceDetails != null &&
                                attendanceDetails.containsKey(studentId);
                          })
                          .map((attendance) {
                            final date = (attendance['date'] as Timestamp).toDate();
                            final formattedDate =
                                '${date.day}-${date.month}-${date.year}';
                            final status = attendance['attendanceDetails'][studentId];
                            return 'Tanggal: $formattedDate - Status: $status';
                          })
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: studentAttendance.isEmpty
                            ? [Text('Tidak ada catatan absensi.')]
                            : studentAttendance.map((record) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(record, style: TextStyle(fontSize: 16)),
                                );
                              }).toList(),
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
