import 'package:flutter/material.dart';

import 'admin/admin_login_page.dart';
import 'pengelolah/pengelola_login_page.dart';

class StaffAccessPage extends StatelessWidget {
  const StaffAccessPage({super.key});

  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

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
        elevation: 0,
        iconTheme: const IconThemeData(color: purple),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE6FA),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: purple,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Akses Pengelola & Admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Silakan pilih akses sesuai peran kamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 36),

                  // Akses Pengelola Kantin
                  _accessCard(
                    icon: Icons.store_rounded,
                    title: 'Pengelola Kantin',
                    subtitle: 'Kelola menu, stok, dan pesanan kantin',
                    onTap: () {
                      _showCanteenSelection(context);
                    },
                  ),

                  const SizedBox(height: 18),

                  // Akses Admin Sistem
                  _accessCard(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin Sistem',
                    subtitle: 'Akses administrasi seluruh sistem',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCanteenSelection(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Kantin yang Dikelola',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 16),

                _canteenOption(
                  parentContext: context,
                  sheetContext: sheetContext,
                  title: 'Kantin Nasi',
                  canteenId: 'nasi',
                  subtitle: 'Menu nasi dan makanan',
                  icon: Icons.rice_bowl_rounded,
                ),

                _canteenOption(
                  parentContext: context,
                  sheetContext: sheetContext,
                  title: 'Kantin Mi & Bakso',
                  canteenId: 'bakso',
                  subtitle: 'Menu mi dan bakso',
                  icon: Icons.ramen_dining_rounded,
                ),

                _canteenOption(
                  parentContext: context,
                  sheetContext: sheetContext,
                  title: 'Kantin Minuman',
                  canteenId: 'minuman',
                  subtitle: 'Berbagai pilihan minuman',
                  icon: Icons.local_cafe_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _canteenOption({
    required BuildContext parentContext,
    required BuildContext sheetContext,
    required String title,
    required String canteenId,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE6FA),
            borderRadius: BorderRadius.circular(14),
          ),
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
        onTap: () {
          // Tutup pilihan kantin terlebih dahulu.
          Navigator.pop(sheetContext);

          // Buka halaman login, bukan dashboard secara langsung.
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (_) => PengelolaLoginPage(canteenId: canteenId),
            ),
          );
        },
      ),
    );
  }

  Widget _accessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: purple, size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF655D6D),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: purple, size: 27),
            ],
          ),
        ),
      ),
    );
  }
}
