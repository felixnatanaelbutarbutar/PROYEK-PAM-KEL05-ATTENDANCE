import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePengumumanPage extends StatefulWidget {
  final String classId;
  final String? pengumumanId; // Null jika membuat pengumuman baru

  const CreatePengumumanPage({Key? key, required this.classId, this.pengumumanId})
      : super(key: key);

  @override
  State<CreatePengumumanPage> createState() => _CreatePengumumanPageState();
}

class _CreatePengumumanPageState extends State<CreatePengumumanPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pengumumanId != null) {
      _fetchPengumumanData();
    }
  }

  Future<void> _fetchPengumumanData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('pengumuman')
          .doc(widget.pengumumanId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _titleController.text = data['title'] ?? '';
        _contentController.text = data['content'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pengumuman: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _savePengumuman() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi pengumuman tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final collection = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('pengumuman');

      if (widget.pengumumanId == null) {
        // Membuat pengumuman baru
        await collection.add({
          'title': _titleController.text,
          'content': _contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Mengedit pengumuman yang ada
        await collection.doc(widget.pengumumanId).update({
          'title': _titleController.text,
          'content': _contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.pengumumanId == null
                ? 'Pengumuman berhasil dibuat.'
                : 'Pengumuman berhasil diperbarui.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pengumuman: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
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
        centerTitle: true,
        title: Text(
          widget.pengumumanId == null ? 'Buat Pengumuman' : 'Edit Pengumuman',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Judul Pengumuman',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan judul pengumuman',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Isi Pengumuman',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 17,
                      decoration: InputDecoration(
                        hintText: 'Tulis isi pengumuman di sini...',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _savePengumuman,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
