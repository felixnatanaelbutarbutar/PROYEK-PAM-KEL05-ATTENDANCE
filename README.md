# 📋 DelCheckIn - Smart Attendance System

_DelCheckIn adalah aplikasi absensi modern berbasis Flutter, dirancang untuk mempermudah proses pencatatan kehadiran mahasiswa di kelas. Dengan antarmuka yang intuitif dan fitur yang lengkap, DelCheckIn membantu pengajar mengelola data absensi dengan efisien dan transparan._

## 🎯 Fitur Utama

- **Manajemen Mahasiswa**
  - Tambahkan data mahasiswa ke kelas tertentu.
  - Hapus atau edit data mahasiswa yang ada.
  - Tampilkan daftar mahasiswa per kelas.

- **Manajemen Pertemuan Kelas**
  - Buat pertemuan baru untuk kelas.
  - Rekam kehadiran mahasiswa berdasarkan pertemuan.
  - Buat Pengumuman untuk kelas.
  - Lihat detail pertemuan termasuk daftar hadir, daftar absen, dan statistik kehadiran.

- **Sistem Login dan Registrasi**
  - Setiap pengguna (dosen) memiliki akun terpisah.
  - Data absensi dan pertemuan tersimpan unik untuk setiap pengguna.

- **Persistensi Data dengan Shared Preferences**
  - Data pengguna, mahasiswa, dan absensi disimpan secara lokal.
  - Setiap pengguna hanya dapat melihat data yang mereka miliki.



## 🛠 Teknologi yang Digunakan

- **Bahasa Pemrograman**: Dart (Flutter Framework)
- **Penyimpanan Data**: Firebase & Shared Preferences 
- **IDE**: Visual Studio Code / Android Studio
- **State Management**: SetState dan Future Builder

## 📂 Struktur Proyek
```sh
📦 delcheckin/
├── 📂 lib/
│   ├── 📄 main.dart                      # Entry point aplikasi
│   ├── 📄 firebase_options.dart          # Konfigurasi Firebase
│   ├── 📂 pages/
│   │   ├── 📂 auth/
│   │   │   ├── 📄 register_dosen.dart        # Halaman registrasi untuk dosen
│   │   │   ├── 📄 register_page_mahasiswa.dart # Halaman registrasi untuk mahasiswa
│   │   ├── 📂 dosen/
│   │   │   ├── 📄 add_student_page.dart      # Halaman untuk menambah mahasiswa
│   │   │   ├── 📄 create_pengumuman.dart     # Halaman untuk membuat pengumuman
│   │   │   ├── 📄 create_pertemuan_page.dart # Halaman untuk membuat pertemuan
│   │   │   ├── 📄 daftar_pertemuan.dart      # Halaman daftar pertemuan
│   │   │   ├── 📄 detail_mahasiswa.dart      # Halaman detail mahasiswa
│   │   │   ├── 📄 detail_pertemuan.dart      # Halaman detail pertemuan
│   │   │   ├── 📄 dosen_home.dart            # Beranda utama dosen
│   │   │   ├── 📄 dosen_profile_page.dart    # Halaman profil dosen
│   │   │   ├── 📄 list_pengumuman.dart       # Halaman daftar pengumuman
│   │   │   ├── 📄 manage_class_page.dart     # Halaman manajemen kelas
│   │   ├── 📂 mahasiswa/
│   │       ├── 📄 class_detail_page.dart          # Halaman detail kelas mahasiswa
│   │       ├── 📄 detail_pengumuman_mahasiswa.dart # Halaman detail pengumuman untuk mahasiswa
│   │       ├── 📄 detail_pertemuan_mahasiswa.dart  # Halaman detail pertemuan untuk mahasiswa
│   │       ├── 📄 list_pengumuman_mahasiswa.dart   # Halaman daftar pengumuman untuk mahasiswa
│   │       ├── 📄 mahasiswa_home_page.dart         # Beranda utama mahasiswa
│   │       ├── 📄 profil_page_mahasiswa.dart       # Halaman profil mahasiswa
│   ├── 📂 widgets/
│       ├── 📄 widget_file_1.dart               # (Contoh file widget, isi sesuai kebutuhan)
│       ├── 📄 widget_file_2.dart               # (Contoh file widget lainnya, isi sesuai kebutuhan)
```
## 🔮 Rencana Pengembangan

- [ ] Integrasi Firebase untuk autentikasi dan database cloud
- [ ] Dashboard Statistik Kehadiran dengan grafik visual
- [ ] Notifikasi Real-Time untuk pengingat pertemuan
- [ ] Fitur Export Data ke format Excel atau PDF

## 👨‍💻 Kontak Pengembang

**Email**: felixnatb@gmail.com

## 📄 Lisensi
MIT License

Copyright (c) [2024] [Felix_Natanael_Butarbutar]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE