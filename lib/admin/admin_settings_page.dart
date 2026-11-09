import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/auth_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF7153A6);
  late Future<Map<String, dynamic>> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _fetchSettings();
  }

  Future<Map<String, dynamic>> _fetchSettings() async {
    final token = await AuthService.instance.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi admin tidak ditemukan. Silakan login kembali.');
    }

    final profile = await AuthService.instance.getProfile();
    if (profile['role'] != 'admin' || profile['status_akun'] != 'aktif') {
      throw Exception(
        'Hanya admin aktif yang dapat membuka pengaturan sistem.',
      );
    }

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/admin/dashboard'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) {
      await AuthService.instance.clearToken();
      throw Exception('Sesi login admin berakhir. Silakan login kembali.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil informasi sistem (HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['success'] != true ||
        decoded['data'] is! Map) {
      throw Exception('Respons informasi sistem dari Laravel tidak valid.');
    }

    return {
      'profile': profile,
      'summary': Map<String, dynamic>.from(decoded['data'] as Map),
    };
  }

  void _refresh() {
    setState(() {
      _settingsFuture = _fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        foregroundColor: darkPurple,
        title: const Text(
          'Pengaturan Sistem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui data dari Laravel',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 46,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final profile = Map<String, dynamic>.from(data['profile'] as Map);
          final summary = Map<String, dynamic>.from(data['summary'] as Map);

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _settingsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _sectionTitle('Informasi Admin'),
                const SizedBox(height: 10),
                _adminCard(profile),
                const SizedBox(height: 24),
                _sectionTitle('Ringkasan Sistem'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Total Pengguna',
                        value: summary['total_pengguna']?.toString() ?? '0',
                        icon: Icons.people_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: 'Total Menu',
                        value: summary['total_menu']?.toString() ?? '0',
                        icon: Icons.restaurant_menu_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE9FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_done_rounded, color: darkPurple),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Informasi ini dimuat langsung dari server Laravel.',
                          style: TextStyle(color: Color(0xFF514365)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF332745),
      ),
    );
  }

  Widget _adminCard(Map<String, dynamic> profile) {
    final name = profile['name']?.toString() ?? 'Admin';
    final email = profile['email']?.toString() ?? '-';

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFF0EBFF),
              child: Text(
                name.isEmpty ? 'A' : name[0].toUpperCase(),
                style: const TextStyle(
                  color: darkPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(email, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 7),
                  const Text(
                    'Administrator aktif',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: purple),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
        ],
      ),
    );
  }
}
