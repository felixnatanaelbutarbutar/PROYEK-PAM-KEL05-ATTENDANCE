import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_student_page.dart';
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
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus', style: GoogleFonts.poppins()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: true, // Hilangkan back button -> flase
        backgroundColor: Colors.blueGrey[900], 
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Kelola Mahasiswa',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            tooltip: 'Buat Pertemuan',
            onPressed: _createPertemuan,
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: 'Tambah Mahasiswa',
            onPressed: _addStudent,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header untuk nama kelas
          Container(
            width: double.infinity,
            color: Colors.blueGrey[900], // Sama dengan AppBar
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              '${widget.className}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
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

                final classData = snapshot.data!.data() as Map<String, dynamic>?;
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

                    // Mengurutkan data berdasarkan NIM secara ascending
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
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DataTable(
                          headingTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blueGrey[900],
                          ),
                          dataTextStyle: GoogleFonts.poppins(fontSize: 13),
                          columnSpacing: 20.0,
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueGrey[100]!,
                          ),
                          columns: [
                            DataColumn(label: Text('NIM')),
                            DataColumn(label: Text('Nama')),
                            DataColumn(label: Text('Kelas')),
                            DataColumn(label: Text('Angkatan')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: sortedStudents.map((student) {
                            final data =
                                student.data() as Map<String, dynamic>;
                            final studentId = student.id;

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  return states.contains(MaterialState.selected)
                                      ? Colors.blueGrey[50]
                                      : null; // Alternating row colors
                                },
                              ),
                              cells: [
                                DataCell(Text(data['nim'] ?? 'N/A')),
                                DataCell(
                                  Text(data['name'] ?? 'N/A'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailMahasiswaPage(
                                          studentId: studentId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                DataCell(Text(data['kelas'] ?? 'N/A')),
                                DataCell(Text(data['angkatan'] ?? 'N/A')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Hapus',
                                        onPressed: () =>
                                            _removeStudent(studentId),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: Icon(Icons.person_add),
        tooltip: 'Tambah Mahasiswa',
        backgroundColor: Colors.blueGrey[900],
      ),
    );
  }
}
