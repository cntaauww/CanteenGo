import 'package:flutter/material.dart';

import 'order_page.dart';

class HomePage extends StatefulWidget {
  final int canteenNumber;

  const HomePage({super.key, required this.canteenNumber});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final Map<String, int> cart = {};

  List<Map<String, dynamic>> get menus {
    if (widget.canteenNumber == 1) {
      return [
        {'name': 'Ayam Geprek', 'price': 'Rp15.000', 'stock': 10, 'icon': '🍗'},
        {'name': 'Es Teh', 'price': 'Rp5.000', 'stock': 15, 'icon': '🥤'},
        {'name': 'Mie Goreng', 'price': 'Rp12.000', 'stock': 6, 'icon': '🍜'},
      ];
    }

    if (widget.canteenNumber == 2) {
      return [
        {'name': 'Nasi Goreng', 'price': 'Rp13.000', 'stock': 8, 'icon': '🍳'},
        {'name': 'Ayam Geprek', 'price': 'Rp15.000', 'stock': 10, 'icon': '🍗'},
        {'name': 'Es Jeruk', 'price': 'Rp6.000', 'stock': 12, 'icon': '🍊'},
      ];
    }

    return [
      {'name': 'Mie Goreng', 'price': 'Rp12.000', 'stock': 6, 'icon': '🍜'},
      {'name': 'Nasi Goreng', 'price': 'Rp13.000', 'stock': 8, 'icon': '🍳'},
      {'name': 'Teh Manis', 'price': 'Rp5.000', 'stock': 15, 'icon': '🧋'},
    ];
  }

  int get totalCartItems {
    int total = 0;

    for (final quantity in cart.values) {
      total += quantity;
    }

    return total;
  }

  void addToCart(Map<String, dynamic> menu) {
    final String menuName = menu['name'];

    setState(() {
      cart[menuName] = (cart[menuName] ?? 0) + 1;
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
      backgroundColor: const Color(0xFFF9F7FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE5FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF9B7DD4),
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CanteenGo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Menu Kantin ${widget.canteenNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Belum ada notifikasi')),
                      );
                    },
                    icon: const Icon(Icons.notifications_none, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // WELCOME CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE5FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo, Mahasiswa 👋',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3B63),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pesan makananmu sekarang,\n'
                            'ambil saat sudah siap!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🍱', style: TextStyle(fontSize: 55)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // SEARCH
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari makanan...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9B7DD4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // MENU TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu Tersedia',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Kantin ${widget.canteenNumber}',
                    style: const TextStyle(
                      color: Color(0xFF9B7DD4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              ...menus.map((menu) => _menuCard(menu)),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderPage(
                  cart: cart,
                  menus: menus,
                  canteenNumber: widget.canteenNumber,
                ),
              ),
            );
          }

          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman profil belum dibuat')),
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

  Widget _menuCard(Map<String, dynamic> menu) {
    final String menuName = menu['name'];
    final int quantity = cart[menuName] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(menu['icon'], style: const TextStyle(fontSize: 32)),
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
                  'Stok: ${menu['stock']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          if (quantity == 0)
            IconButton(
              onPressed: () {
                addToCart(menu);
              },
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF9B7DD4),
                size: 32,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E9FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (cart[menuName]! > 1) {
                          cart[menuName] = cart[menuName]! - 1;
                        } else {
                          cart.remove(menuName);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.remove,
                      size: 18,
                      color: Color(0xFF8B6CC7),
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),

                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  IconButton(
                    onPressed: () {
                      addToCart(menu);
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Color(0xFF8B6CC7),
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
