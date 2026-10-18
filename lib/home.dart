import 'package:flutter/material.dart';

import 'data/menu_store.dart';
import 'order_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final int canteenNumber;

  const HomePage({super.key, required this.canteenNumber});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color pink = Color(0xFFF4A6C5);
  static const Color lilac = Color(0xFFE9DDF8);
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFFFF8FC);

  final MenuStore menuStore = MenuStore.instance;

  int selectedIndex = 0;
  String searchQuery = '';

  final Map<String, int> cart = {};
  final TextEditingController searchController = TextEditingController();

  String get canteenName {
    switch (widget.canteenNumber) {
      case 1:
        return 'Kantin Nasi';
      case 2:
        return 'Kantin Mi & Bakso';
      case 3:
        return 'Kantin Minuman';
      default:
        return 'Kantin';
    }
  }

  // ID kantin harus sama dengan ID yang digunakan halaman PK.
  String get canteenId {
    switch (widget.canteenNumber) {
      case 1:
        return 'nasi';
      case 2:
        return 'bakso';
      case 3:
        return 'minuman';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    menuStore.addListener(_onMenusChanged);
  }

  void _onMenusChanged() {
    if (!mounted) return;

    setState(() {
      // Perbarui tampilan ketika PK mengubah data menu.
    });
  }

  // Membaca menu dari sumber data yang sama dengan halaman PK.
  // Harga diubah menjadi String agar kompatibel dengan OrderPage
  // yang sebelumnya menerima harga seperti "Rp13.000".
  List<Map<String, dynamic>> get menus {
    return menuStore.getMenus(canteenId).map((item) {
      final menu = Map<String, dynamic>.from(item);

      final dynamic rawPrice = menu['price'];
      menu['price'] = _formatPrice(rawPrice);

      menu['stock'] = _toInt(menu['stock']);
      menu['available'] = menu['available'] != false;
      menu['icon'] = menu['icon']?.toString() ?? '🍽️';
      menu['image'] = menu['image']?.toString() ?? '';

      return menu;
    }).toList();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPrice(dynamic value) {
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.tryParse(cleaned);
      if (amount == null) return value;
      return 'Rp${_thousands(amount)}';
    }

    final amount = _toInt(value);
    return 'Rp${_thousands(amount)}';
  }

  String _thousands(int amount) {
    final digits = amount.toString();
    final result = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(digits[i]);
    }

    return result.toString();
  }

  List<Map<String, dynamic>> get filteredMenus {
    final query = searchQuery.trim().toLowerCase();

    final availableMenus = menus.where((menu) {
      return menu['name'].toString().toLowerCase().contains(query);
    }).toList();

    return availableMenus;
  }

  int get totalCartItems =>
      cart.values.fold(0, (total, quantity) => total + quantity);

  @override
  void dispose() {
    menuStore.removeListener(_onMenusChanged);
    searchController.dispose();
    super.dispose();
  }

  void addToCart(Map<String, dynamic> menu) {
    final String name = menu['name'].toString();
    final int stock = _toInt(menu['stock']);
    final bool available = menu['available'] != false;
    final int quantity = cart[name] ?? 0;

    if (!available || stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maaf, menu ini sedang tidak tersedia.')),
      );
      return;
    }

    if (quantity >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah pesanan sudah mencapai batas stok.'),
        ),
      );
      return;
    }

    setState(() {
      cart[name] = quantity + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ditambahkan ke keranjang'),
        backgroundColor: purple,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void decreaseQuantity(String name) {
    setState(() {
      if ((cart[name] ?? 0) > 1) {
        cart[name] = cart[name]! - 1;
      } else {
        cart.remove(name);
      }
    });
  }

  void openOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
          cart: cart,
          menus: menus,
          canteenNumber: widget.canteenNumber,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFAD8E8), lilac],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: purple,
                      size: 28,
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
                            color: darkPurple,
                          ),
                        ),
                        Text(
                          canteenName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B7D9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Belum ada notifikasi baru.'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: purple,
                      size: 27,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // BANNER SAMBUTAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFBE0EC), Color(0xFFF1E8FC)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hai, Mahasiswa! 💗',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkPurple,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Pilih makanan favoritmu dan pesan dengan mudah!',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: darkPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.lunch_dining_rounded,
                      size: 58,
                      color: purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // PENCARIAN MENU
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: pink.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari menu di $canteenName...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFAA9DB6),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: purple),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // JUDUL MENU
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Menu Tersedia',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: lilac,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredMenus.length} menu',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                'Yuk, pilih menu favoritmu!',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 18),

              if (filteredMenus.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 45, color: purple),
                      SizedBox(height: 10),
                      Text(
                        'Menu tidak ditemukan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Coba cari dengan kata lain.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...filteredMenus.map(_menuCard),
            ],
          ),
        ),
      ),

      // NAVIGASI BAWAH
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: lilac,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            setState(() {
              selectedIndex = 0;
            });
            openOrders();
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          } else {
            setState(() {
              selectedIndex = 0;
            });
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: purple),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(Icons.receipt_long_rounded, color: purple),
            ),
            label: 'Pesanan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: purple),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // KARTU MENU
  Widget _menuCard(Map<String, dynamic> menu) {
    final String menuName = menu['name'].toString();
    final int quantity = cart[menuName] ?? 0;
    final int stock = _toInt(menu['stock']);
    final bool available = menu['available'] != false;
    final bool isOutOfStock = stock <= 0 || !available;
    final bool isAtStockLimit = quantity >= stock;
    final String imagePath = menu['image']?.toString() ?? '';
    final String iconText = menu['icon']?.toString() ?? '🍽️';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFF0E5F5)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FOTO MENU
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: imagePath.isEmpty
                ? _imageFallback(iconText)
                : Image.asset(
                    imagePath,
                    width: 100,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _imageFallback(iconText);
                    },
                  ),
          ),

          const SizedBox(width: 15),

          // NAMA, HARGA, DAN STOK
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menu['price'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE85D9E),
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? const Color(0xFFFFE5E5)
                        : const Color(0xFFF0E9FC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    !available
                        ? 'Tidak tersedia'
                        : stock <= 0
                        ? 'Stok habis'
                        : 'Stok tersedia: $stock',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock ? Colors.red.shade700 : darkPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // TOMBOL TAMBAH ATAU PENGATUR JUMLAH
          if (quantity == 0)
            Material(
              color: isOutOfStock ? Colors.grey.shade300 : pink,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isOutOfStock ? null : () => addToCart(menu),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 25),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFF6D3E3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: isOutOfStock || isAtStockLimit
                        ? null
                        : () => addToCart(menu),
                    icon: Icon(
                      Icons.add_rounded,
                      color: isOutOfStock || isAtStockLimit
                          ? Colors.grey
                          : const Color(0xFFD65C97),
                    ),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => decreaseQuantity(menuName),
                    icon: const Icon(Icons.remove_rounded, color: darkPurple),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback(String iconText) {
    return Container(
      width: 100,
      height: 105,
      color: const Color(0xFFFFEAF2),
      alignment: Alignment.center,
      child: Text(iconText, style: const TextStyle(fontSize: 40)),
    );
  }
}
