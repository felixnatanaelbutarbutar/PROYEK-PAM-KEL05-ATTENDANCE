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
  String? _meetingTitle;
  Map<String, String> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    // Pastikan dialog ditampilkan setelah build context selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPertemuanDialog();
    });
  }

  Future<void> _showPertemuanDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Buat Pertemuan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input judul pertemuan
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul Pertemuan',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _meetingTitle = value;
                  });
                },
              ),
              SizedBox(height: 15),
              // Pilih tanggal pertemuan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () async {
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
                },
                child: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal'
                      : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  style: GoogleFonts.poppins(
                      color: const Color.fromARGB(162, 0, 0, 0)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
              ),
              onPressed: () {
                if (_meetingTitle == null || _meetingTitle!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Judul pertemuan harus diisi')),
                  );
                  return;
                }
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tanggal harus dipilih')),
                  );
                  return;
                }
                Navigator.pop(context);
              },
              child: Text('Simpan', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAttendance() async {
    if (_meetingTitle == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi data pertemuan terlebih dahulu')),
      );
      return;
    }

    try {
      final pertemuanRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('pertemuan');

      // Ambil daftar mahasiswa dari Firestore berdasarkan kelas
      final classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .get();

      final classData = classSnapshot.data() as Map<String, dynamic>?;
      final studentIds = classData?['students'] as List<dynamic>? ?? [];

      // Buat daftar mahasiswa berdasarkan NIM
      List<Map<String, dynamic>> studentsList = [];
      Map<String, String> attendanceData = {};

      for (var studentId in studentIds) {
        final studentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .get();

        if (studentSnapshot.exists) {
          final studentData = studentSnapshot.data() as Map<String, dynamic>;

          // Ambil NIM mahasiswa
          final nim = studentData['nim'] ?? 'Unknown';

          // Tambahkan ke daftar mahasiswa
          studentsList.add({
            'nim': nim, // Gunakan NIM
            'name': studentData['name'] ?? 'Unknown',
          });

          // Tambahkan ke data attendance dengan default 'Tidak Hadir'
          attendanceData[nim] = _attendanceStatus[studentId] ?? 'Hadir';
        }
      }

      // Simpan data pertemuan ke Firestore
      await pertemuanRef.add({
        'judul': _meetingTitle,
        'tanggal': Timestamp.fromDate(_selectedDate!),
        'students': studentsList, // Daftar mahasiswa berdasarkan NIM
        'attendance': attendanceData, // Kehadiran berdasarkan NIM
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pertemuan berhasil disimpan!')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
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
          'Buat Pertemuan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mata Kuliah: ${widget.className}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color.fromARGB(
                          196, 0, 0, 0), // Use a color that matches your theme
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Judul Pertemuan: ${_meetingTitle ?? "Belum diatur"}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(
                          179, 0, 0, 0), // Softer color for less emphasis
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tanggal: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : "Belum dipilih"}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(
                          179, 0, 0, 0), // Softer color for less emphasis
                    ),
                  ),
                ],
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

                final classData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final studentIds =
                    classData?['students'] as List<dynamic>? ?? [];

                if (studentIds.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada mahasiswa di kelas ini.',
                      style:
                          GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
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
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection:
                                  Axis.vertical, // Vertical scrolling
                              child: DataTable(
                                headingTextStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blueGrey[900],
                                ),
                                dataTextStyle:
                                    GoogleFonts.poppins(fontSize: 13),
                                columnSpacing: 19.0,
                                columns: [
                                  DataColumn(
                                      label: Container( width: 50, child: Text('NIM'))),
                                  DataColumn(
                                      label: Container(
                                          width: 170,child: Text('Nama'))), // Adjust width as needed
                                  DataColumn(label: Text('Keterangan')),
                                ],
                                rows: sortedStudents.map((student) {
                                  final data =
                                      student.data() as Map<String, dynamic>;
                                  final studentId = student.id;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(data['nim'] ?? 'N/A')),
                                      DataCell(
                                        Container(
                                          width:
                                              150, // Fixed width to allow wrapping
                                          child: Text(
                                            data['name'] ?? 'N/A',
                                            overflow: TextOverflow
                                                .visible, // Allow text to wrap
                                            maxLines:
                                                2, // Maximum number of lines
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        DropdownButton<String>(
                                          value: _attendanceStatus[studentId] ??
                                              'Hadir',
                                          items: [
                                            'Hadir',
                                            'Alpha',
                                            'Sakit',
                                            'Izin'
                                          ]
                                              .map((status) => DropdownMenuItem(
                                                    value: status,
                                                    child: Text(status),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _attendanceStatus[studentId] =
                                                  value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
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
