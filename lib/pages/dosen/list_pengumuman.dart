import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import intl
import 'package:proyek_pam_kel5/pages/dosen/create_pengumuman.dart';

class ListPengumumanPage extends StatelessWidget {
  final String classId; // ID kelas untuk menampilkan pengumuman

  const ListPengumumanPage({Key? key, required this.classId}) : super(key: key);

  Future<void> _deletePengumuman(
      BuildContext context, String pengumumanId) async {
    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('pengumuman')
          .doc(pengumumanId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengumuman berhasil dihapus.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus pengumuman: $e',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            return const Center(child: CircularProgressIndicator());
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
                                'Apakah Anda yakin ingin menghapus pengumuman ini?'),
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
                          _deletePengumuman(context, pengumuman.id);
                        }
                      },
                    ),
                    const Icon(Icons.edit, color: Colors.blue),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePengumumanPage(
                        classId: classId,
                        pengumumanId: pengumuman.id, // Kirim ID pengumuman untuk edit
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
