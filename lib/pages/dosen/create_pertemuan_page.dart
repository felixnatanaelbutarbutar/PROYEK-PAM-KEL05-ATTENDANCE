import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePertemuanPage extends StatefulWidget {
  final String classId;
  final String className;

  const CreatePertemuanPage({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  _CreatePertemuanPageState createState() => _CreatePertemuanPageState();
}

class _CreatePertemuanPageState extends State<CreatePertemuanPage> {
  DateTime? _selectedDate;
  Map<String, String> _attendanceStatus = {};

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
      );
      return;
    }

    try {
      // Lokasi penyimpanan di Firestore
      final pertemuanRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('pertemuan');

      // Data yang disimpan
      await pertemuanRef.add({
        'tanggal': _selectedDate!.toIso8601String(), // Tanggal pertemuan
        'attendanceDetails': _attendanceStatus, // Detail absensi
        'hadir': _attendanceStatus.values.where((status) => status == 'Hadir').length,
        'absen': _attendanceStatus.values.where((status) => status != 'Hadir').length,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pertemuan berhasil disimpan!')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan absensi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        title: Text(
          'Buat Pertemuan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Nama kelas
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '${widget.className}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          // Tanggal pertemuan
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                'Tanggal Pertemuan: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
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
                          DataColumn(label: Text('Keterangan')),
                        ],
                        rows: sortedStudents.map((student) {
                          final data =
                              student.data() as Map<String, dynamic>;
                          final studentId = student.id;

                          return DataRow(
                            cells: [
                              DataCell(Text(data['nim'] ?? 'N/A')),
                              DataCell(Text(data['name'] ?? 'N/A')),
                              DataCell(Text(data['kelas'] ?? 'N/A')),
                              DataCell(
                                DropdownButton<String>(
                                  value: _attendanceStatus[studentId] ?? 'Hadir',
                                  items: ['Hadir', 'Alpha', 'Sakit', 'Izin']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status,
                                                style: GoogleFonts.poppins()),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _attendanceStatus[studentId] = value!;
                                    });
                                  },
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
