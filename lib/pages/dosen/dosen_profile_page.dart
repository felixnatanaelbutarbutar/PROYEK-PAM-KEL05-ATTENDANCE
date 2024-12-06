import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DosenProfilePage extends StatelessWidget {
  final String dosenId;

  DosenProfilePage({required this.dosenId});

  Future<Map<String, dynamic>?> _fetchDosenProfile() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(dosenId).get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Dosen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchDosenProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                'Data dosen tidak ditemukan.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.blue.shade100,
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.person_outline,
                      size: 80,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    _buildTableRow('Nama', data['name'] ?? 'Tidak diketahui'),
                    _buildTableRow('Email', data['email'] ?? 'Tidak diketahui'),
                    _buildTableRow('NIDN', data['nidn'] ?? 'Tidak tersedia'),
                    _buildTableRow('Prodi', data['prodi'] ?? 'Tidak tersedia'),
                    _buildTableRow(
                        'Jabatan', data['jabatan_akademik'] ?? 'Tidak tersedia'),
                    _buildTableRow(
                        'Golongan', data['golongan_kepangkatan'] ?? 'Tidak tersedia'),
                    _buildTableRow('Ikatan Kerja',
                        data['status_ikatan_kerja'] ?? 'Tidak tersedia'),
                    _buildTableRow('Aktif Start',
                        data['aktif_start'] ?? 'Tidak tersedia'),
                    _buildTableRow(
                        'Aktif End', data['aktif_end'] ?? 'Tidak tersedia'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
