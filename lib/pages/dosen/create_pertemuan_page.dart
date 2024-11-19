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
      // Simpan absensi ke Firestore
      await FirebaseFirestore.instance.collection('attendances').add({
        'classId': widget.classId,
        'date': _selectedDate,
        'attendanceDetails': _attendanceStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pertemuan berhasil disimpan!')),
      );
      Navigator.pop(context);
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'mahasiswa')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Mengurutkan data berdasarkan NIM
                final students = snapshot.data!.docs;
                final sortedStudents = students.toList()
                  ..sort((a, b) {
                    final nimA = (a.data() as Map<String, dynamic>)['nim'] ?? '';
                    final nimB = (b.data() as Map<String, dynamic>)['nim'] ?? '';
                    return nimA.compareTo(nimB);
                  });

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columnSpacing: 12.0,
                    columns: [
                      DataColumn(label: Text('NIM', style: GoogleFonts.poppins())),
                      DataColumn(label: Text('Nama', style: GoogleFonts.poppins())),
                      DataColumn(label: Text('Kelas', style: GoogleFonts.poppins())),
                      DataColumn(
                          label: Text('Keterangan', style: GoogleFonts.poppins())),
                    ],
                    rows: sortedStudents.map((student) {
                      final data = student.data() as Map<String, dynamic>;
                      final studentId = student.id;

                      return DataRow(
                        cells: [
                          DataCell(Text(data['nim'] ?? 'N/A',
                              style: GoogleFonts.poppins())),
                          DataCell(Text(data['name'] ?? 'N/A',
                              style: GoogleFonts.poppins())),
                          DataCell(Text(data['kelas'] ?? 'N/A',
                              style: GoogleFonts.poppins())),
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
            ),
          ),
        ],
      ),
    );
  }
}
