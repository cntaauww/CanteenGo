import 'package:flutter/material.dart';

import 'admin/admin_login_page.dart';
import 'pengelolah/pengelola_dashboard_page.dart';

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
                  context: sheetContext,
                  title: 'Kantin Nasi',
                  canteenId: '1',
                ),
                _canteenOption(
                  context: sheetContext,
                  title: 'Kantin Mi & Bakso',
                  canteenId: '2',
                ),
                _canteenOption(
                  context: sheetContext,
                  title: 'Kantin Minuman',
                  canteenId: '3',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _canteenOption({
    required BuildContext context,
    required String title,
    required String canteenId,
  }) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.store_rounded, color: purple),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.pop(context);

          Navigator.push(
            this.contextForNavigation(context),
            MaterialPageRoute(
              builder: (_) => PengelolaDashboardPage(canteenId: canteenId),
            ),
          );
        },
      ),
    );
  }

  BuildContext contextForNavigation(BuildContext context) {
    return context;
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
