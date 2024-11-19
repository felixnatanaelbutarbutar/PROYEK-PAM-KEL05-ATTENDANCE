import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus mahasiswa ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus'),
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
      appBar: AppBar(
        title: Text('Kelola Mahasiswa - ${widget.className}'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _createPertemuan,
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _addStudent,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final classData = snapshot.data!.data() as Map<String, dynamic>?;
          final studentIds = classData?['students'] as List<dynamic>? ?? [];

          if (studentIds.isEmpty) {
            return Center(child: Text('Tidak ada mahasiswa di kelas ini.'));
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
                  final nimA = (a.data() as Map<String, dynamic>)['nim'] ?? '';
                  final nimB = (b.data() as Map<String, dynamic>)['nim'] ?? '';
                  return nimA.compareTo(nimB);
                });

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12.0, // Mengatur jarak antar kolom
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
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _removeStudent(studentId),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: Icon(Icons.person_add),
        tooltip: 'Tambah Mahasiswa',
      ),
    );
  }
}
