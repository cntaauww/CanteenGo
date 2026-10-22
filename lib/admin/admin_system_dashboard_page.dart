import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_canteen_page.dart';

class AdminSystemDashboardPage extends StatefulWidget {
  const AdminSystemDashboardPage({super.key});

  @override
  State<AdminSystemDashboardPage> createState() =>
      _AdminSystemDashboardPageState();
}

class _AdminSystemDashboardPageState extends State<AdminSystemDashboardPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF7153A6);
  static const Color background = Color(0xFFFAF8FF);

  static const String apiUrl = 'http://127.0.0.1:8000/api/admin/dashboard';

  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboard();
  }

  Future<Map<String, dynamic>> _fetchDashboard() async {
    final response = await http
        .get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data dashboard '
        '(HTTP ${response.statusCode}).',
      );
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;

    if (result['success'] != true || result['data'] == null) {
      throw Exception('Respons API dashboard tidak valid.');
    }

    return Map<String, dynamic>.from(result['data'] as Map);
  }

  void _refreshDashboard() {
    setState(() {
      _dashboardFuture = _fetchDashboard();
    });
  }

  void _showFeatureMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature belum terhubung ke Laravel.')),
    );
  }

  void _openCanteenManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminCanteenPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: darkPurple,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'CanteenGo Admin',
              style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Perbarui data',
            icon: const Icon(Icons.refresh_rounded, color: darkPurple),
            onPressed: _refreshDashboard,
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: darkPurple),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE9DFFF), Color(0xFFFFEAF3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Admin Sistem',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: darkPurple,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Selamat datang di pusat administrasi CanteenGo.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF5E526E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Ringkasan Sistem',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF332745),
                    ),
                  ),

                  const SizedBox(height: 14),

                  FutureBuilder<Map<String, dynamic>>(
                    future: _dashboardFuture,
                    builder: (context, snapshot) {
                      final isLoading =
                          snapshot.connectionState == ConnectionState.waiting;

                      final hasError = snapshot.hasError;
                      final data = snapshot.data;

                      final totalPengguna =
                          data?['total_pengguna']?.toString() ?? '—';

                      final totalMenu = data?['total_menu']?.toString() ?? '—';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 700
                                  ? 4
                                  : constraints.maxWidth >= 450
                                  ? 2
                                  : 1;

                              return GridView.count(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: columns == 1 ? 2.5 : 1.2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _statCard(
                                    icon: Icons.people_alt_rounded,
                                    title: 'Total Pengguna',
                                    value: isLoading
                                        ? '...'
                                        : hasError
                                        ? '!'
                                        : totalPengguna,
                                    color: const Color(0xFF5479D8),
                                  ),
                                  _statCard(
                                    icon: Icons.store_rounded,
                                    title: 'Total Kantin',
                                    value: '—',
                                    color: const Color(0xFF39966A),
                                  ),
                                  _statCard(
                                    icon: Icons.restaurant_menu_rounded,
                                    title: 'Total Menu',
                                    value: isLoading
                                        ? '...'
                                        : hasError
                                        ? '!'
                                        : totalMenu,
                                    color: const Color(0xFFD28B31),
                                  ),
                                  _statCard(
                                    icon: Icons.receipt_long_rounded,
                                    title: 'Total Pesanan',
                                    value: '—',
                                    color: const Color(0xFF9666C9),
                                  ),
                                ],
                              );
                            },
                          ),

                          if (hasError) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Data dashboard gagal dimuat.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB3261E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${snapshot.error}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  TextButton.icon(
                                    onPressed: _refreshDashboard,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Coba lagi'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Menu Administrasi',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF332745),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _featureCard(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: 'Manajemen Pengguna',
                    subtitle: 'Kelola akun mahasiswa dan pengelola kantin.',
                    onTap: () {
                      _showFeatureMessage(context, 'Manajemen Pengguna');
                    },
                  ),

                  _featureCard(
                    context,
                    icon: Icons.store_rounded,
                    title: 'Manajemen Kantin',
                    subtitle: 'Lihat daftar menu berdasarkan nomor kantin.',
                    onTap: _openCanteenManagement,
                  ),

                  _featureCard(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Monitoring Pesanan',
                    subtitle: 'Pantau pesanan dari seluruh kantin.',
                    onTap: () {
                      _showFeatureMessage(context, 'Monitoring Pesanan');
                    },
                  ),

                  _featureCard(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'Pengaturan Sistem',
                    subtitle: 'Pengaturan dan informasi administrasi.',
                    onTap: () {
                      _showFeatureMessage(context, 'Pengaturan Sistem');
                    },
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'CanteenGo • Administrasi Sistem',
                      style: TextStyle(color: Color(0xFF9B90AE), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF332745),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
    BuildContext context, {
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
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFF0EBFF),
          child: Icon(icon, color: purple),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: purple),
        onTap: onTap,
      ),
    );
  }
}
