import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/auth_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF7153A6);
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  String selectedRole = 'semua';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await AuthService.instance.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sesi admin tidak ditemukan. Silakan login kembali.');
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/users'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil pengguna (HTTP ${response.statusCode}).',
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (result['success'] != true || result['data'] is! List) {
        throw Exception('Format data pengguna tidak valid.');
      }

      final data = (result['data'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;

      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final nim = (user['nim'] ?? '').toString().toLowerCase();
      final role = (user['role'] ?? '').toString();

      final matchesSearch =
          name.contains(searchQuery) ||
          email.contains(searchQuery) ||
          nim.contains(searchQuery);

      final matchesRole = selectedRole == 'semua' || role == selectedRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> updateUserStatus(
    Map<String, dynamic> user,
    String newStatus,
  ) async {
    final userId = user['id'];

    try {
      final token = await AuthService.instance.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sesi admin tidak ditemukan.');
      }

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/status'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'status_akun': newStatus}),
          )
          .timeout(const Duration(seconds: 15));

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || result['success'] != true) {
        throw Exception(result['message'] ?? 'Gagal memperbarui status akun.');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Status berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );

      await fetchUsers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> confirmStatusChange(Map<String, dynamic> user) async {
    final currentStatus = user['status_akun']?.toString() ?? 'aktif';
    final newStatus = currentStatus == 'aktif' ? 'nonaktif' : 'aktif';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Status Akun?'),
        content: Text(
          'Apakah kamu yakin ingin mengubah status '
          '${user['name']} menjadi $newStatus?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await updateUserStatus(user, newStatus);
    }
  }

  String roleLabel(String role) {
    switch (role) {
      case 'mahasiswa':
        return 'Mahasiswa';
      case 'pk':
        return 'Pengelola Kantin';
      case 'admin':
        return 'Admin Sistem';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = users.where((u) => u['status_akun'] == 'aktif').length;
    final inactiveCount = users
        .where((u) => u['status_akun'] == 'nonaktif')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        foregroundColor: darkPurple,
        title: const Text(
          'Manajemen Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : fetchUsers,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui data',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchUsers,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Total Pengguna',
                      users.length.toString(),
                      Icons.people_alt_rounded,
                      purple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      'Aktif',
                      activeCount.toString(),
                      Icons.check_circle_rounded,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      'Nonaktif',
                      inactiveCount.toString(),
                      Icons.block_rounded,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama, email, atau NIM...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEDE6F7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEDE6F7)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase().trim();
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Filter berdasarkan role',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'semua',
                    child: Text('Semua Pengguna'),
                  ),
                  DropdownMenuItem(
                    value: 'mahasiswa',
                    child: Text('Mahasiswa'),
                  ),
                  DropdownMenuItem(
                    value: 'pk',
                    child: Text('Pengelola Kantin'),
                  ),
                  DropdownMenuItem(value: 'admin', child: Text('Admin Sistem')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Daftar Pengguna',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF332745),
                ),
              ),

              const SizedBox(height: 12),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (errorMessage != null)
                _errorWidget()
              else if (filteredUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('Pengguna tidak ditemukan.')),
                )
              else
                ...filteredUsers.map(_userCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE6F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11)),
          Text(
            value,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? '';
    final status = user['status_akun']?.toString() ?? 'nonaktif';
    final isActive = status == 'aktif';
    final isAdmin = role == 'admin';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFF0EBFF),
                  child: Icon(
                    role == 'mahasiswa'
                        ? Icons.school_rounded
                        : role == 'pk'
                        ? Icons.store_rounded
                        : Icons.admin_panel_settings_rounded,
                    color: purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']?.toString() ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        user['email']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Role: ${roleLabel(role)}'),
            if (user['nim'] != null) Text('NIM: ${user['nim']}'),
            if (user['nomor_kantin'] != null)
              Text('Nomor Kantin: ${user['nomor_kantin']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Status: ${isActive ? 'Aktif' : 'Nonaktif'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
                const Spacer(),
                if (!isAdmin)
                  TextButton.icon(
                    onPressed: () => confirmStatusChange(user),
                    icon: Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                    style: TextButton.styleFrom(
                      foregroundColor: isActive ? Colors.red : Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 35),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: fetchUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
