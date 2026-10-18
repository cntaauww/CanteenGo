import 'package:flutter/material.dart';

import 'canteen_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE6D9FF), Color(0xFFF8E8F8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(38),
                  ),
                  child: const Icon(
                    Icons.ramen_dining_rounded,
                    size: 76,
                    color: purple,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'CanteenGo',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: darkPurple,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Pesan Makanan, Tanpa Antre!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Pesan makanan kantin kampus dengan mudah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Color(0xFF76698D),
                  ),
                ),

                const SizedBox(height: 38),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CanteenPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: purple.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Mulai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                const Divider(
                  color: Color(0xFFE5DDF4),
                  indent: 35,
                  endIndent: 35,
                ),

                const SizedBox(height: 15),

                const Text(
                  'CanteenGo',
                  style: TextStyle(
                    color: purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Mudah • Cepat • Efisien',
                  style: TextStyle(color: Color(0xFF9B90AE), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
