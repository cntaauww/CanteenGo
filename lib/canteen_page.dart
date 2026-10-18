import 'package:flutter/material.dart';

import 'home.dart';

class CanteenPage extends StatelessWidget {
  const CanteenPage({super.key});

  static const Color lilac = Color(0xFF9B7DD4);
  static const Color darkLilac = Color(0xFF7153A6);
  static const Color softPink = Color(0xFFFFEAF3);
  static const Color background = Color(0xFFFAF8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Logo dan nama aplikasi
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: lilac,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CanteenGo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkLilac,
                        ),
                      ),
                      Text(
                        'Pesan mudah, makan nyaman',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Banner sambutan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE9DFFF), Color(0xFFFFEAF3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lapar, ya? 💗',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: darkLilac,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pilih kantin favoritmu dan pesan makanan '
                      'tanpa harus mengantre lama.',
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
                'Pilih Kantin',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF332745),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mau makan atau minum apa hari ini?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 18),

              _canteenCard(
                context: context,
                number: 1,
                title: 'Kantin Nasi',
                description: 'Aneka nasi dan lauk favorit',
                icon: Icons.rice_bowl_rounded,
                color: const Color(0xFFFFE8D6),
              ),

              const SizedBox(height: 14),

              _canteenCard(
                context: context,
                number: 2,
                title: 'Kantin Mi & Bakso',
                description: 'Mi, bakso, dan makanan berkuah',
                icon: Icons.ramen_dining_rounded,
                color: const Color(0xFFE8E0FF),
              ),

              const SizedBox(height: 14),

              _canteenCard(
                context: context,
                number: 3,
                title: 'Kantin Minuman',
                description: 'Minuman segar dan hangat',
                icon: Icons.local_cafe_rounded,
                color: const Color(0xFFFFE4EF),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'CanteenGo • Pesan dengan praktis ✨',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _canteenCard({
    required BuildContext context,
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HomePage(canteenNumber: number)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDE6F7)),
            boxShadow: [
              BoxShadow(
                color: lilac.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(icon, size: 34, color: darkLilac),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332745),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lihat menu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkLilac,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: lilac,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
