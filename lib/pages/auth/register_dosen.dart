import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterDosenPage extends StatefulWidget {
  @override
  _RegisterDosenPageState createState() => _RegisterDosenPageState();
}

class _RegisterDosenPageState extends State<RegisterDosenPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nidnController = TextEditingController();
  final TextEditingController _prodiController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _golonganController = TextEditingController();
  final TextEditingController _statusIkatanKerjaController =
      TextEditingController();
  final TextEditingController _aktifStartController = TextEditingController();
  final TextEditingController _aktifEndController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerDosen() async {
    setState(() => _isLoading = true);
    try {
      // Buat akun di Firebase Authentication
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Tambahkan data dosen ke Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': user.email,
          'role': 'dosen',
          'uid': user.uid,
          'nidn': _nidnController.text.trim(),
          'prodi': _prodiController.text.trim(),
          'jabatan_akademik': _jabatanController.text.trim(),
          'golongan_kepangkatan': _golonganController.text.trim(),
          'status_ikatan_kerja': _statusIkatanKerjaController.text.trim(),
          'aktif_start': _aktifStartController.text.trim(),
          'aktif_end': _aktifEndController.text.trim(),
        });

        // Sukses
        _showDialog('Pendaftaran berhasil!', 'Akun dosen berhasil dibuat.');
        _clearFields();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showDialog('Gagal', 'Email sudah terdaftar.');
      } else if (e.code == 'weak-password') {
        _showDialog('Gagal', 'Password terlalu lemah.');
      } else {
        _showDialog('Gagal', e.message ?? 'Terjadi kesalahan.');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _nidnController.clear();
    _prodiController.clear();
    _jabatanController.clear();
    _golonganController.clear();
    _statusIkatanKerjaController.clear();
    _aktifStartController.clear();
    _aktifEndController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Dosen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nidnController,
                decoration: InputDecoration(
                  labelText: 'NIDN',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _prodiController,
                decoration: InputDecoration(
                  labelText: 'Prodi',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _jabatanController,
                decoration: InputDecoration(
                  labelText: 'Jabatan Akademik',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _golonganController,
                decoration: InputDecoration(
                  labelText: 'Golongan Kepangkatan',
                  prefixIcon: Icon(Icons.star),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _statusIkatanKerjaController,
                decoration: InputDecoration(
                  labelText: 'Status Ikatan Kerja',
                  prefixIcon: Icon(Icons.assignment_ind),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _aktifStartController,
                decoration: InputDecoration(
                  labelText: 'Aktif Start',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _aktifEndController,
                decoration: InputDecoration(
                  labelText: 'Aktif End',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerDosen,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Register Dosen',
                          style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
