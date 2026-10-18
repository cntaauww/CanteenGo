import 'package:flutter/material.dart';

import 'pengelolah/pengelola_dashboard_page.dart';

const Color purple = Color(0xFF9B7DD4);
const Color darkPurple = Color(0xFF7153A6);
const Color background = Color(0xFFFAF8FF);

class StaffAccessPage extends StatelessWidget {
  const StaffAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Akses Khusus',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: background,
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 48,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Akses Pengelola & Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan masuk menggunakan akun sesuai peran kamu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                _accessCard(
                  context,
                  icon: Icons.store_rounded,
                  title: 'Pengelola Kantin',
                  subtitle: 'Kelola menu, stok, dan pesanan kantin',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StaffLoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _accessCard(
                  context,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Sistem',
                  subtitle: 'Akses administrasi sistem',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login Admin Sistem belum tersedia.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _accessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: darkPurple, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: purple,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final String username = usernameController.text.trim().toLowerCase();
    final String password = passwordController.text;

    String? canteenId;

    if (username == 'pengelola_nasi' && password == 'nasi123') {
      canteenId = 'nasi';
    } else if (username == 'pengelola_minum' && password == 'minum123') {
      canteenId = 'minuman';
    } else if (username == 'pengelola_bakso' && password == 'bakso123') {
      canteenId = 'bakso';
    }

    if (canteenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah. Silakan coba lagi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PengelolaDashboardPage(canteenId: canteenId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Login Pengelola',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: background,
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.storefront_rounded, size: 76, color: purple),
                const SizedBox(height: 16),
                const Text(
                  'Selamat Datang!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke akun pengelola kantin kamu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4DDF4)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: purple,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: purple,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4DDF4)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akun Demo Pengelola',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Kantin Nasi: pengelola_nasi / nasi123'),
                      SizedBox(height: 6),
                      Text('Kantin Minuman: pengelola_minum / minum123'),
                      SizedBox(height: 6),
                      Text('Kantin Bakso: pengelola_bakso / bakso123'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
