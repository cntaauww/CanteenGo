import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminCanteenPage extends StatefulWidget {
  const AdminCanteenPage({super.key});

  @override
  State<AdminCanteenPage> createState() => _AdminCanteenPageState();
}

class _AdminCanteenPageState extends State<AdminCanteenPage> {
  int selectedCanteen = 1;
  bool isLoading = false;
  String? errorMessage;
  List<dynamic> menus = [];

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse('$baseUrl/menus?nomor_kantin=$selectedCanteen');

      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic result = jsonDecode(response.body);

        if (result is Map && result['data'] is List) {
          setState(() {
            menus = List<dynamic>.from(result['data'] as List);
          });
        } else {
          setState(() {
            menus = [];
            errorMessage = 'Format data menu dari Laravel tidak sesuai.';
          });
        }
      } else {
        setState(() {
          menus = [];
          errorMessage = 'Gagal mengambil menu (HTTP ${response.statusCode}).';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        menus = [];
        errorMessage =
            'Tidak dapat terhubung ke Laravel. '
            'Pastikan server dan database aktif.';
      });

      debugPrint('Kesalahan mengambil menu: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  int toInt(dynamic value) {
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ??
        double.tryParse(value?.toString() ?? '')?.toInt() ??
        0;
  }

  bool toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value?.toString().toLowerCase();
    return text == '1' || text == 'true';
  }

  String formatRupiah(dynamic value) {
    final number = toInt(value);
    final digits = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kantin'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading ? null : fetchMenus,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              initialValue: selectedCanteen,
              decoration: const InputDecoration(
                labelText: 'Pilih Nomor Kantin',
                border: OutlineInputBorder(),
              ),
              items: [1, 2, 3].map((number) {
                return DropdownMenuItem<int>(
                  value: number,
                  child: Text('Kantin $number'),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        selectedCanteen = value;
                        menus = [];
                      });

                      fetchMenus();
                    },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: fetchMenus,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : menus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada menu di Kantin '
                          '$selectedCanteen.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: fetchMenus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];

                      final nama =
                          menu['nama_menu']?.toString() ?? 'Tanpa nama';
                      final harga = formatRupiah(menu['harga']);
                      final stok = toInt(menu['stok']);
                      final tersedia = toBool(menu['tersedia']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.deepOrange,
                            ),
                          ),
                          title: Text(
                            nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Harga: $harga\n'
                            'Stok: $stok\n'
                            'Status: ${tersedia ? 'Tersedia' : 'Tidak tersedia'}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
