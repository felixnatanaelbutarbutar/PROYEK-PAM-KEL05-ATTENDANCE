import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Dosen')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('dosenId', isEqualTo: dosenId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final classes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              return ListTile(
                title: Text(classData['className']),
                subtitle: Text('Jumlah Mahasiswa: ${classData['students'].length}'),
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addClass(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

// Dialog widget now moved into the same file
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
      title: Text('Tambah Kelas Baru'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: 'Nama Kelas',
                hintText: 'Masukkan nama kelas',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kelas tidak boleh kosong';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_classNameController.text);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}