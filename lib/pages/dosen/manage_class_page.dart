import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyek_pam_kel5/pages/dosen/create_pengumuman.dart';
import 'package:proyek_pam_kel5/pages/dosen/list_pengumuman.dart';
// import 'package:proyek_pam_kel5/pages/dosen/daftar_pengumuman.dart';
import 'add_student_page.dart';
import 'daftar_pertemuan.dart';
import 'create_pertemuan_page.dart';
import 'detail_mahasiswa.dart';

class ManageStudentPage extends StatefulWidget {
  final String classId;
  final String className;

  const ManageStudentPage({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  _ManageStudentPageState createState() => _ManageStudentPageState();
}

class _ManageStudentPageState extends State<ManageStudentPage> {
  Future<void> _removeStudent(String studentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi', style: GoogleFonts.poppins()),
        content: Text(
          'Apakah Anda yakin ingin menghapus mahasiswa ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child:
                Text('Hapus', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .update({
        'students': FieldValue.arrayRemove([studentId]),
      });
    }
  }

  void _addStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(
          classId: widget.classId,
          className: widget.className,
        ),
      ),
    );
  }

  void _openDaftarPertemuan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarPertemuanPage(classId: widget.classId),
      ),
    );
  }

  void _createPertemuan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePertemuanPage(
          classId: widget.classId,
          className: widget.className,
        ),
      ),
    );
  }

  void _createPengumuman() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePengumumanPage(
          classId: widget.classId,
          // className: widget.className,
        ),
      ),
    );
  }

  void _openDaftarPengumuman() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ListPengumumanPage(classId: widget.classId,),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
          'Kelola Mahasiswa',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            tooltip: 'Daftar Pertemuan',
            onPressed: _openDaftarPertemuan,
          ),
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            tooltip: 'Tambah Mahasiswa',
            onPressed: _addStudent,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 66, 121, 215), Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                widget.className,
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: const Color.fromARGB(142, 255, 255, 255),
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: <Color>[
                        const Color.fromARGB(255, 3, 106, 191),
                        const Color.fromARGB(255, 20, 21, 22),
                      ],
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Baris pertama
                Row(
                  children: [
                    // Tombol "Buat Pengumuman"
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createPengumuman,
                        icon: Icon(Icons.notifications, color: Colors.white),
                        label: Text(
                          'Buat Pengumuman',
                          style: GoogleFonts.poppins(
                              fontSize: 13.5, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Spasi antar tombol
                    // Tombol "Lihat Pengumuman"
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openDaftarPengumuman,
                        icon: Icon(Icons.notifications_outlined,
                            color: Colors.white),
                        label: Text(
                          'Lihat Pengumuman',
                          style: GoogleFonts.poppins(
                              fontSize: 13.5, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Spasi antar baris
                // Baris kedua
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createPertemuan,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Buat Pertemuan',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .doc(widget.classId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final classData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final studentIds =
                    classData?['students'] as List<dynamic>? ?? [];

                if (studentIds.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada mahasiswa di kelas ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: studentIds)
                      .snapshots(),
                  builder: (context, studentSnapshot) {
                    if (!studentSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final students = studentSnapshot.data!.docs;

                    final sortedStudents = students.toList()
                      ..sort((a, b) {
                        final nimA =
                            (a.data() as Map<String, dynamic>)['nim'] ?? '';
                        final nimB =
                            (b.data() as Map<String, dynamic>)['nim'] ?? '';
                        return nimA.compareTo(nimB);
                      });

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 15.0,
                        headingTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                        ),
                        dataTextStyle: GoogleFonts.poppins(fontSize: 13),
                        columns: [
                          DataColumn(label: Text('NIM')),
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Kelas')),
                          DataColumn(label: Text('Angkatan')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: sortedStudents.map((student) {
                          final data = student.data() as Map<String, dynamic>;
                          final studentId = student.id;

                          return DataRow(
                            cells: [
                              DataCell(Text(data['nim'] ?? 'N/A')),
                              DataCell(
                                Text(data['name'] ?? 'N/A'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailMahasiswaPage(
                                        studentId: studentId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              DataCell(Text(data['kelas'] ?? 'N/A')),
                              DataCell(Text(data['angkatan'] ?? 'N/A')),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Hapus',
                                  onPressed: () => _removeStudent(studentId),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
