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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F7FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B7DD4)),
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
  int selectedIndex = 0;
  String selectedCanteen = 'Kantin 1';

  // Keranjang pesanan
  Map<String, int> cart = {};

  final List<Map<String, dynamic>> menus = [
    {'name': 'Ayam Geprek', 'price': 'Rp15.000', 'stock': 10, 'icon': '🍗'},
    {'name': 'Nasi Goreng', 'price': 'Rp13.000', 'stock': 8, 'icon': '🍳'},
    {'name': 'Es Teh', 'price': 'Rp5.000', 'stock': 15, 'icon': '🥤'},
    {'name': 'Mie Goreng', 'price': 'Rp12.000', 'stock': 6, 'icon': '🍜'},
  ];

  // Menghitung total jumlah makanan di keranjang
  int get totalCartItems {
    int total = 0;

    for (final quantity in cart.values) {
      total += quantity;
    }

    return total;
  }

  // Menambahkan makanan ke keranjang
  void addToCart(Map<String, dynamic> menu) {
    if (menu['stock'] <= 0) {
      return;
    }

    setState(() {
      cart[menu['name']] = (cart[menu['name']] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menu['name']} ditambahkan ke pesanan'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DEFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF8B6CC7),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CanteenGo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pesan makanan jadi lebih mudah',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= WELCOME CARD =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE7DCFF), Color(0xFFF1EBFF)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, Mahasiswa 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  'Mau makan apa hari ini?',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🍱', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= SEARCH =================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari makanan atau minuman...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF9B7DD4),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= KANTIN =================
                    const Text(
                      'Pilih Kantin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _canteenButton('Kantin 1'),
                          _canteenButton('Kantin 2'),
                          _canteenButton('Kantin 3'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================= MENU =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Menu Tersedia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

                    ...menus.map((menu) => _menuCard(menu)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          // Untuk sementara hanya menampilkan pesan
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  totalCartItems == 0
                      ? 'Belum ada pesanan'
                      : 'Ada $totalCartItems item di pesanan',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Pesanan',
          ),

          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ================= BUTTON KANTIN =================
  Widget _canteenButton(String name) {
    final bool isSelected = selectedCanteen == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCanteen = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9B7DD4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCCEFF)),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= MENU CARD =================
  Widget _menuCard(Map<String, dynamic> menu) {
    final int quantity = cart[menu['name']] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(menu['icon'], style: const TextStyle(fontSize: 34)),
            ),
          ),

          const SizedBox(width: 14),

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
                  'Stok tersedia: ${menu['stock']}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),

          // Jumlah item
          if (quantity > 0)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF8B6CC7),
                ),
              ),
            ),

          // Tombol tambah
          IconButton(
            onPressed: menu['stock'] > 0
                ? () {
                    addToCart(menu);
                  }
                : null,
            icon: const Icon(Icons.add_circle, size: 32),
            color: const Color(0xFF9B7DD4),
          ),
        ],
      ),
    );
  }
}
