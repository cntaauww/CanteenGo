import 'package:flutter/material.dart';

import 'staff_access_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Kartu profil mahasiswa
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9DFFF), Color(0xFFFFEAF3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded, size: 42, color: purple),
                ),
                SizedBox(height: 12),
                Text(
                  'Mahasiswa',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Selamat datang di CanteenGo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: darkPurple),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Riwayat pesanan
          _menuItem(
            icon: Icons.receipt_long_rounded,
            title: 'Riwayat Pesanan',
            subtitle: 'Lihat pesanan sebelumnya',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Halaman riwayat pesanan akan '
                    'dihubungkan berikutnya.',
                  ),
                ),
              );
            },
          ),

          // Bantuan
          _menuItem(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan',
            subtitle: 'Informasi penggunaan aplikasi',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CanteenGo',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Pesan Makanan, Tanpa Antre!'),
                  SizedBox(height: 8),
                  Text(
                    'CanteenGo adalah aplikasi pemesanan '
                    'makanan kantin kampus yang memudahkan '
                    'mahasiswa memesan makanan tanpa harus '
                    'mengantre lama.',
                  ),
                ],
              );
            },
          ),

          // Tentang aplikasi
          _menuItem(
            icon: Icons.info_outline_rounded,
            title: 'Tentang Aplikasi',
            subtitle: 'Mudah • Cepat • Efisien',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CanteenGo',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Aplikasi pemesanan makanan kantin kampus.'),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          // Judul akses khusus
          const Text(
            'AKSES KHUSUS',
            style: TextStyle(
              color: purple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          // Tombol akses pengelola dan admin
          _menuItem(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Akses Pengelola & Admin',
            subtitle: 'Login khusus petugas sistem',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffAccessPage()),
              );
            },
          ),

          const SizedBox(height: 20),

          // Footer
          const Center(
            child: Text(
              'CanteenGo • Pesan dengan praktis',
              style: TextStyle(fontSize: 12, color: Color(0xFF9B90AE)),
            ),
          ),
        ],
      ),
    );
  }

  // Komponen kartu menu
  static Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0EBFF),
          child: Icon(icon, color: purple),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded, color: purple),
        onTap: onTap,
      ),
    );
  }
}
