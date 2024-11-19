import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentPage extends StatefulWidget {
  final String classId;
  final String className;

  const AddStudentPage({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final Map<String, bool> _selectedStudents = {};
  String _selectedKelas = 'Semua'; // Default untuk filter kelas
  final List<String> _kelasOptions = ['Semua', '31TI1', '31TI2', '31TI3'];
  bool _selectAll = false;

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'mahasiswa');

      // Jika filter kelas dipilih, tambahkan filter query
      if (_selectedKelas != 'Semua') {
        query = query.where('kelas', isEqualTo: _selectedKelas);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          'nim': data['nim'] ?? 'N/A',
          'name': data['name'] ?? 'N/A',
          'angkatan': data['angkatan'] ?? 'N/A',
          'kelas': data['kelas'] ?? 'N/A',
          'asrama': data['asrama'] ?? 'N/A',
        };
      }).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<void> _saveStudents() async {
    final selectedIds = _selectedStudents.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada mahasiswa yang dipilih')),
      );
      return;
    }

    final classRef =
        FirebaseFirestore.instance.collection('classes').doc(widget.classId);
    await classRef.update({
      'students': FieldValue.arrayUnion(selectedIds),
    });

    Navigator.pop(context);
  }

  void _toggleSelectAll(bool? value, List<Map<String, dynamic>> students) {
    setState(() {
      _selectAll = value ?? false;
      for (var student in students) {
        final studentId = student['id'];
        if (studentId != null) {
          _selectedStudents[studentId] = _selectAll;
        }
      }
    });
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _selectedKelas,
      items: _kelasOptions.map((kelas) {
        return DropdownMenuItem<String>(
          value: kelas,
          child: Text(kelas),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedKelas = value ?? 'Semua';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Mahasiswa ke ${widget.className}'),
        actions: [
          IconButton(
            onPressed: _saveStudents,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Kelas:'),
                _buildFilterDropdown(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan saat memuat data.'));
                }

                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return Center(child: Text('Tidak ada mahasiswa yang tersedia.'));
                }

                // Inisialisasi selected students dengan null check
                for (var student in students) {
                  final studentId = student['id'];
                  if (studentId != null) {
                    _selectedStudents[studentId] ??= false;
                  }
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 12.0, // Memperkecil jarak antar kolom
                    columns: [
                      DataColumn(label: Text('NIM')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Angkatan')),
                      DataColumn(label: Text('Kelas')),
                      DataColumn(label: Text('Asrama')),
                      DataColumn(
                        label: Row(
                          children: [
                            Text('Pilih Semua'),
                            Checkbox(
                              value: _selectAll,
                              onChanged: (value) => _toggleSelectAll(value, students),
                            ),
                          ],
                        ),
                      ),
                    ],
                    rows: students.map((student) {
                      final studentId = student['id'];
                      return DataRow(
                        cells: [
                          DataCell(Text(student['nim'] ?? 'N/A')),
                          DataCell(Text(student['name'] ?? 'N/A')),
                          DataCell(Text(student['angkatan'] ?? 'N/A')),
                          DataCell(Text(student['kelas'] ?? 'N/A')),
                          DataCell(Text(student['asrama'] ?? 'N/A')),
                          DataCell(
                            Checkbox(
                              value: _selectedStudents[studentId] ?? false,
                              onChanged: (isChecked) {
                                setState(() {
                                  _selectedStudents[studentId] = isChecked ?? false;
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
