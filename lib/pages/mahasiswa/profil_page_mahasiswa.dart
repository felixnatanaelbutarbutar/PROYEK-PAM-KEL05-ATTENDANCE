import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final String mahasiswaId;

  const ProfilePage({Key? key, required this.mahasiswaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profil Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF283E51), Color(0xFF4B79A1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(mahasiswaId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data == null) {
                return const Center(
                  child: Text(
                    'Data mahasiswa tidak ditemukan.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      // Profile picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: data['photoUrl'] != null
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child: data['photoUrl'] == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name and email
                      Text(
                        data['name'] ?? 'Nama Tidak Ditemukan',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        data['email'] ?? 'Email Tidak Ditemukan',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Details card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildProfileItem(
                                icon: Icons.badge,
                                label: 'NIM',
                                value: data['nim'] ?? 'Tidak Ditemukan',
                              ),
                              _buildProfileItem(
                                icon: Icons.calendar_today,
                                label: 'Angkatan',
                                value: data['angkatan'] ?? 'Tidak Ditemukan',
                              ),
                              _buildProfileItem(
                                icon: Icons.class_,
                                label: 'Kelas',
                                value: data['kelas'] ?? 'Tidak Ditemukan',
                              ),
                              _buildProfileItem(
                                icon: Icons.home,
                                label: 'Asrama',
                                value: data['asrama'] ?? 'Tidak Ditemukan',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Back button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueGrey[900],
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey[900], size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
