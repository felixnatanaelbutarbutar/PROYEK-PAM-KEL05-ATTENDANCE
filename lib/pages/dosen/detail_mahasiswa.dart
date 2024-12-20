import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailMahasiswaPage extends StatelessWidget {
  final String nim; // NIM Mahasiswa
  final String classId; // ID Kelas

  const DetailMahasiswaPage(
      {Key? key, required this.nim, required this.classId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekap Kehadiran Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .collection('pertemuan')
            .snapshots(),
        builder: (context, pertemuanSnapshot) {
          if (pertemuanSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!pertemuanSnapshot.hasData ||
              pertemuanSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada data pertemuan.'));
          }

          final pertemuanDocs = pertemuanSnapshot.data!.docs;
          int totalHadir = 0;
          int totalPertemuan = pertemuanDocs.length;

          // Hitung total kehadiran
          for (var pertemuan in pertemuanDocs) {
            final data = pertemuan.data() as Map<String, dynamic>;
            final attendanceData =
                data['attendance'] as Map<String, dynamic>?; // Ambil attendance

            if (attendanceData != null && attendanceData.containsKey(nim)) {
              final status =
                  attendanceData[nim]; // Ambil status berdasarkan nim
              if (status == 'Hadir') {
                totalHadir++;
              }
            }
          }

          double kehadiranPersentase =
              totalPertemuan > 0 ? (totalHadir / totalPertemuan) * 100 : 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'Rekap Kehadiran Mahasiswa',
                //   style: TextStyle(
                //       fontSize: 22,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.blueAccent),
                // ),
                const SizedBox(height: 20),

                // Card untuk detail absensi
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.event_available,
                              color: Colors.blueAccent, size: 40),
                          title: Text(
                            'Total Pertemuan',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            '$totalPertemuan',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black54),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green, size: 40),
                          title: Text(
                            'Total Kehadiran',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            '$totalHadir',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black54),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.percent,
                              color: Colors.orange, size: 40),
                          title: Text(
                            'Persentase Kehadiran',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            '${kehadiranPersentase.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Progress bar untuk persentase kehadiran
                Text(
                  'Progres Kehadiran:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: kehadiranPersentase / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    kehadiranPersentase >= 75.0 ? Colors.green : Colors.red,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 20),

                // Status kelayakan
                Center(
                  child: Text(
                    kehadiranPersentase >= 75.0
                        ? 'Status: Layak UTS/UAS ✅'
                        : 'Status: Tidak Layak UTS/UAS ❌',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kehadiranPersentase >= 75.0
                          ? Colors.green
                          : Colors.red,
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
