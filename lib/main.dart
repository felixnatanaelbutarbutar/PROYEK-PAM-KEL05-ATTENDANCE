import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/auth/login_page.dart';
import 'pages/dosen/dosen_home.dart';
import 'pages/mahasiswa/mahasiswa_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk FirebaseFirestore

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DelCheckIn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Halaman pertama adalah SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Periksa status login saat aplikasi dibuka
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      // Jika email disimpan, cek apakah user masih terautentikasi
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Ambil data pengguna dari Firestore untuk menentukan role
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'unknown';
          if (role == 'dosen') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DosenHomePage()),
            );
          } else if (role == 'mahasiswa') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MahasiswaHomePage()),
            );
          } else {
            _navigateToLogin(); // Role tidak valid
          }
        } else {
          _navigateToLogin(); // User tidak ditemukan di Firestore
        }
      } else {
        _navigateToLogin(); // Sesi Firebase sudah habis
      }
    } else {
      _navigateToLogin(); // Tidak ada data email disimpan
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
