import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_student_page.dart';

class DosenHomePage extends StatelessWidget {
  final String dosenId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _addClass(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => _AddClassDialog(),
    );

    if (result != null) {
      await FirebaseFirestore.instance.collection('classes').add({
        'className': result,
        'dosenId': dosenId,
        'students': [],
      });
    }
  }

  Future<void> _editClass(BuildContext context, String classId, String currentName) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditClassDialog(currentName: currentName),
    );

    if (result != null && result.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .update({'className': result});
    }
  }

  Future<void> _deleteClass(BuildContext context, String classId, String className) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus', style: GoogleFonts.poppins()),
        content: Text(
          'Apakah Anda yakin ingin menghapus mata kuliah "$className"?',
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
      await FirebaseFirestore.instance.collection('classes').doc(classId).delete();
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout', style: GoogleFonts.poppins()),
        content: Text(
          'Apakah Anda yakin ingin logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout. Silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar with Gradient
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Dashboard Dosen',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                    onPressed: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .where('dosenId', isEqualTo: dosenId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final classes = snapshot.data!.docs;

                  if (classes.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada mata kuliah.',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classData = classes[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageStudentPage(
                                classId: classData.id,
                                className: classData['className'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.class_,
                                  size: 39,
                                  color: Colors.blue,
                                ),
                                Text(
                                  classData['className'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Jumlah Mahasiswa: ${classData['students'].length}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit Nama',
                                      onPressed: () => _editClass(context, classData.id, classData['className']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Hapus Kelas',
                                      onPressed: () => _deleteClass(context, classData.id, classData['className']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addClass(context),
        child: Icon(Icons.add),
        tooltip: 'Tambah Mata Kuliah',
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

// Dialog widget for adding a new class
class _AddClassDialog extends StatefulWidget {
  @override
  _AddClassDialogState createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<_AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Mata Kuliah Baru', style: GoogleFonts.poppins()),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _classNameController,
          decoration: InputDecoration(
            labelText: 'Nama Mata Kuliah',
            hintText: 'Masukkan nama mata kuliah',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama mata kuliah tidak boleh kosong';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_classNameController.text);
            }
          },
          child: Text('Simpan', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

// Dialog widget for editing class name
class _EditClassDialog extends StatefulWidget {
  final String currentName;

  const _EditClassDialog({Key? key, required this.currentName}) : super(key: key);

  @override
  _EditClassDialogState createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<_EditClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classNameController;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Nama Mata Kuliah', style: GoogleFonts.poppins()),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _classNameController,
          decoration: InputDecoration(
            labelText: 'Nama Mata Kuliah',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_classNameController.text);
            }
          },
          child: Text('Simpan', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
