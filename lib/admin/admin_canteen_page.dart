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
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menus?nomor_kantin=$selectedCanteen'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        setState(() {
          menus = result['data'] ?? [];
        });
      } else {
        setState(() {
          errorMessage = 'Gagal mengambil data menu (${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Tidak dapat terhubung ke Laravel. Pastikan server aktif.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
            onPressed: fetchMenus,
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
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCanteen = value;
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
                ? const Center(
                    child: Text(
                      'Belum ada menu untuk kantin ini.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];

                      final nama =
                          menu['nama_menu']?.toString() ?? 'Tanpa nama';
                      final harga = menu['harga']?.toString() ?? '0';
                      final stok = menu['stok']?.toString() ?? '0';
                      final tersedia =
                          menu['tersedia'] == true || menu['tersedia'] == 1;

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
                            'Harga: Rp$harga\n'
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
