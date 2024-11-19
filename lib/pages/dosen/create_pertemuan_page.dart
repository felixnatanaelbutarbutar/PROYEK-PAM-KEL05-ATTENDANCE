import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        'date': _selectedDate, // Timestamp
        'attendanceDetails': _attendanceStatus, // Map<String, String>
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
        title: Text('Buat Pertemuan - ${widget.className}'),
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
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Tanggal Pertemuan: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    columns: [
                      DataColumn(label: Text('NIM')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Kelas')),
                      DataColumn(label: Text('Keterangan')),
                    ],
                    rows: sortedStudents.map((student) {
                      final data = student.data() as Map<String, dynamic>;
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
                                        child: Text(status),
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
