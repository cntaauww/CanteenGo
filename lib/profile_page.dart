import 'package:flutter/material.dart';

import 'mahasiswa_login_page.dart';
import 'order_history_page.dart';
import 'staff_access_page.dart';
import 'services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final savedUser = await AuthService.instance.getSavedUser();

      if (!mounted) return;

      setState(() {
        user = savedUser;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        user = null;
        isLoading = false;
      });
    }
  }

  String getUserName() {
    final name = user?['nama'] ?? user?['name'] ?? user?['nama_lengkap'];

    if (name == null || name.toString().trim().isEmpty) {
      return 'Mahasiswa';
    }

    return name.toString();
  }

  String getUserEmail() {
    return (user?['email'] ?? 'Email tidak tersedia').toString();
  }

  Future<void> openStudentLogin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MahasiswaLoginPage()),
    );

    if (!mounted) return;

    if (result == true) {
      await loadProfile();
    }
  }

  Future<void> openOrderHistory() async {
    final token = await AuthService.instance.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      final loginResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const MahasiswaLoginPage()),
      );

      if (loginResult != true || !mounted) return;

      await loadProfile();
      if (!mounted) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
    );
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu login kembali untuk membuat pesanan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: purple),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => isLoggingOut = true);

    try {
      await AuthService.instance.logout();

      if (!mounted) return;

      setState(() {
        user = null;
        isLoggingOut = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kamu berhasil logout.')));
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoggingOut = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
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
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isLoggedIn ? getUserName() : 'Mahasiswa',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isLoggedIn
                            ? getUserEmail()
                            : 'Login untuk mengakses akunmu',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: darkPurple),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLoggedIn ? 'Akun Mahasiswa' : 'Belum Login',
                          style: const TextStyle(
                            color: purple,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                if (!isLoggedIn)
                  _menuItem(
                    icon: Icons.login_rounded,
                    title: 'Login Mahasiswa',
                    subtitle: 'Masuk untuk melanjutkan pesanan',
                    onTap: openStudentLogin,
                  )
                else
                  _menuItem(
                    icon: Icons.verified_user_rounded,
                    title: 'Akun Mahasiswa',
                    subtitle: getUserEmail(),
                    onTap: () {},
                  ),

                _menuItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Riwayat Pesanan',
                  subtitle: 'Lihat pesanan sebelumnya',
                  onTap: openOrderHistory,
                ),

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
                          'CanteenGo memudahkan mahasiswa '
                          'memesan makanan kantin kampus '
                          'tanpa harus mengantre lama.',
                        ),
                      ],
                    );
                  },
                ),

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

                if (isLoggedIn) ...[
                  const SizedBox(height: 8),
                  _menuItem(
                    icon: Icons.logout_rounded,
                    title: isLoggingOut ? 'Sedang Logout...' : 'Logout',
                    subtitle: 'Keluar dari akun mahasiswa',
                    onTap: isLoggingOut ? () {} : logout,
                  ),
                ],

                const SizedBox(height: 18),

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

                _menuItem(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Akses Pengelola & Admin',
                  subtitle: 'Login khusus petugas sistem',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaffAccessPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

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
