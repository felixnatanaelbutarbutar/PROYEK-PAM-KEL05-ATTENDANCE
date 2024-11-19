import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterMahasiswaPage extends StatefulWidget {
  @override
  _RegisterMahasiswaPageState createState() => _RegisterMahasiswaPageState();
}

class _RegisterMahasiswaPageState extends State<RegisterMahasiswaPage> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();

  String? _selectedKelas;
  String? _selectedAsrama;

  bool _isLoading = false;

  final List<String> _kelasOptions = ['31TI1', '31TI2', '31TI3'];
  final List<String> _asramaOptions = ['Pniel', 'Jati'];

  Future<void> _registerMahasiswa() async {
    if (_selectedKelas == null || _selectedAsrama == null) {
      _showDialog('Gagal', 'Harap pilih Kelas dan Asrama.');
      return;
    }

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
        // Tambahkan data mahasiswa ke Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nim': _nimController.text.trim(),
          'name': _nameController.text.trim(),
          'email': user.email,
          'angkatan': _angkatanController.text.trim(),
          'kelas': _selectedKelas,
          'asrama': _selectedAsrama,
          'role': 'mahasiswa',
          'uid': user.uid,
        });

        // Sukses
        _showDialog('Pendaftaran berhasil!', 'Akun mahasiswa berhasil dibuat.');
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
    _nimController.clear();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _angkatanController.clear();
    _selectedKelas = null;
    _selectedAsrama = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Mahasiswa'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nimController,
                decoration: InputDecoration(
                  labelText: 'NIM',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              TextField(
                controller: _angkatanController,
                decoration: InputDecoration(
                  labelText: 'Angkatan',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                onChanged: (value) {
                  setState(() {
                    _selectedKelas = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Kelas',
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                items: _kelasOptions.map((kelas) {
                  return DropdownMenuItem(
                    value: kelas,
                    child: Text(kelas),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedAsrama,
                onChanged: (value) {
                  setState(() {
                    _selectedAsrama = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Asrama',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                items: _asramaOptions.map((asrama) {
                  return DropdownMenuItem(
                    value: asrama,
                    child: Text(asrama),
                  );
                }).toList(),
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
              SizedBox(height: 20),
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
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerMahasiswa,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Register Mahasiswa',
                          style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
