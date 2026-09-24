import 'package:flutter/material.dart';

void main() {
  runApp(const CanteenGoApp());
}

class CanteenGoApp extends StatelessWidget {
  const CanteenGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CanteenGo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB79CED)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F6FF),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedCanteen = 'Kantin 1';

  final List<Map<String, dynamic>> menus = [
    {'name': 'Ayam Geprek', 'price': 'Rp15.000', 'stock': 10, 'icon': '🍗'},
    {'name': 'Nasi Goreng', 'price': 'Rp13.000', 'stock': 8, 'icon': '🍳'},
    {'name': 'Es Teh', 'price': 'Rp5.000', 'stock': 15, 'icon': '🥤'},
    {'name': 'Mie Goreng', 'price': 'Rp12.000', 'stock': 6, 'icon': '🍜'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5D7FF),
        elevation: 0,
        title: const Text(
          'CanteenGo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sapaan
            const Text(
              'Halo, Mahasiswa 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              'Mau makan apa hari ini?',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Pilih kantin
            const Text(
              'Pilih Kantin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD8C7F5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCanteen,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'Kantin 1',
                      child: Text('🍱 Kantin 1'),
                    ),
                    DropdownMenuItem(
                      value: 'Kantin 2',
                      child: Text('🍜 Kantin 2'),
                    ),
                    DropdownMenuItem(
                      value: 'Kantin 3',
                      child: Text('🥤 Kantin 3'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCanteen = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Judul menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menu Tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  selectedCanteen,
                  style: const TextStyle(
                    color: Color(0xFF8B6CC7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Daftar menu
            ...menus.map((menu) => _buildMenuCard(menu)),
          ],
        ),
      ),

      // Navigasi bawah
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon makanan
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(menu['icon'], style: const TextStyle(fontSize: 32)),
            ),
          ),

          const SizedBox(width: 14),

          // Informasi makanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  menu['price'],
                  style: const TextStyle(
                    color: Color(0xFF8B6CC7),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Stok: ${menu['stock']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: menu['stock'] > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Tombol tambah
          IconButton(
            onPressed: menu['stock'] > 0
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${menu['name']} ditambahkan ke pesanan'),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.add_circle),
            color: const Color(0xFF9B7DD4),
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}
