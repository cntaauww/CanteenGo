import 'package:flutter/material.dart';

import 'order_masuk_page.dart';

const Color appBg = Color(0xFFF9F7FF);
const Color appPurple = Color(0xFF9B7DD4);
const Color appDark = Color(0xFF4A3B63);

class PengelolaHomePage extends StatelessWidget {
  const PengelolaHomePage({super.key});

  // Nomor kantin yang dikelola akun ini.
  // Ubah menjadi 2 atau 3 untuk akun kantin lainnya.
  static const int canteenNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(
        backgroundColor: appBg,
        title: const Text(
          'Dashboard Pengelola',
          style: TextStyle(color: appDark, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: appPurple,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.storefront, color: Colors.white, size: 38),
                SizedBox(height: 14),
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Kelola pesanan kantin dengan mudah.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appDark,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  icon: Icons.receipt_long,
                  title: 'Pesanan Masuk',
                  value: '2',
                  color: appPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  icon: Icons.pending_actions,
                  title: 'Perlu Konfirmasi',
                  value: '1',
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Menu Pengelola',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appDark,
            ),
          ),

          const SizedBox(height: 14),

          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE5FF),
                child: Icon(Icons.receipt_long, color: appPurple),
              ),
              title: const Text(
                'Daftar Pesanan Masuk',
                style: TextStyle(fontWeight: FontWeight.bold, color: appDark),
              ),
              subtitle: const Text('Lihat dan kelola pesanan mahasiswa'),
              trailing: const Icon(Icons.chevron_right, color: appPurple),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const OrderMasukPage(canteenNumber: canteenNumber),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: appDark, fontSize: 12)),
        ],
      ),
    );
  }
}
