import 'package:flutter/material.dart';

import '../data/menu_store.dart';

class PengelolaDashboardPage extends StatefulWidget {
  final String canteenId;

  const PengelolaDashboardPage({super.key, required this.canteenId});

  @override
  State<PengelolaDashboardPage> createState() => _PengelolaDashboardPageState();
}

class _PengelolaDashboardPageState extends State<PengelolaDashboardPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFFFF8FC);

  final MenuStore menuStore = MenuStore.instance;

  int selectedIndex = 0;

  String get canteenName {
    switch (widget.canteenId) {
      case 'minuman':
        return 'Kantin Minuman';
      case 'bakso':
        return 'Kantin Mi & Bakso';
      default:
        return 'Kantin Nasi';
    }
  }

  IconData get canteenIcon {
    switch (widget.canteenId) {
      case 'minuman':
        return Icons.local_cafe_rounded;
      case 'bakso':
        return Icons.ramen_dining_rounded;
      default:
        return Icons.rice_bowl_rounded;
    }
  }

  List<Map<String, dynamic>> get menus => menuStore
      .getMenus(widget.canteenId)
      .map((menu) => Map<String, dynamic>.from(menu))
      .toList();

  late final List<Map<String, dynamic>> orders = _initialOrders();

  @override
  void initState() {
    super.initState();
    menuStore.addListener(_onMenusChanged);
  }

  void _onMenusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    menuStore.removeListener(_onMenusChanged);
    super.dispose();
  }

  List<Map<String, dynamic>> _initialOrders() {
    switch (widget.canteenId) {
      case 'minuman':
        return [
          {
            'code': 'CGM001',
            'menu': 'Es Teh Manis',
            'quantity': 1,
            'status': 'Menunggu',
          },
          {
            'code': 'CGM002',
            'menu': 'Es Cokelat',
            'quantity': 2,
            'status': 'Diproses',
          },
        ];
      case 'bakso':
        return [
          {
            'code': 'CGB001',
            'menu': 'Bakso Biasa',
            'quantity': 1,
            'status': 'Menunggu',
          },
          {
            'code': 'CGB002',
            'menu': 'Bakso Urat',
            'quantity': 2,
            'status': 'Selesai',
          },
        ];
      default:
        return [
          {
            'code': 'CG001',
            'menu': 'Nasi Goreng',
            'quantity': 1,
            'status': 'Menunggu',
          },
          {
            'code': 'CG002',
            'menu': 'Nasi Ayam Geprek',
            'quantity': 2,
            'status': 'Diproses',
          },
          {
            'code': 'CG003',
            'menu': 'Nasi Kuning',
            'quantity': 1,
            'status': 'Selesai',
          },
        ];
    }
  }

  int get totalStock => menus.fold<int>(
    0,
    (total, menu) => total + ((menu['stock'] as int?) ?? 0),
  );

  int get availableMenus =>
      menus.where((menu) => menu['available'] == true).length;

  int _menuIndex(Map<String, dynamic> menu) {
    final currentMenus = menuStore.getMenus(widget.canteenId);

    // Utamakan identitas berdasarkan nama menu.
    // Nama menu sebaiknya unik di dalam setiap kantin.
    return currentMenus.indexWhere((item) => item['name'] == menu['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(canteenIcon, color: purple, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CanteenGo',
                    style: TextStyle(
                      color: darkPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    canteenName,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout_rounded, color: darkPurple),
              onPressed: _confirmLogout,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [_buildDashboard(), _buildMenuPage(), _buildOrdersPage()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE9DDF8),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: purple),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_rounded),
            selectedIcon: Icon(Icons.restaurant_menu_rounded, color: purple),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: purple),
            label: 'Pesanan',
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu akan kembali ke halaman sebelumnya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildDashboard() {
    final currentMenus = menus;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFAD8E8), Color(0xFFE9DDF8)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, Pengelola! 💗',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selamat datang di $canteenName. '
                'Kelola menu dan pesanan kantinmu '
                'dengan lebih mudah.',
                style: const TextStyle(color: darkPurple, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Ringkasan Kantin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total Menu',
                '${currentMenus.length}',
                Icons.restaurant_menu_rounded,
                const Color(0xFFE9DDF8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Menu Aktif',
                '$availableMenus',
                Icons.check_circle_outline_rounded,
                const Color(0xFFFFE5EF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total Stok',
                '$totalStock',
                Icons.inventory_2_outlined,
                const Color(0xFFFFE8D6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Pesanan',
                '${orders.length}',
                Icons.receipt_long_rounded,
                const Color(0xFFE2F4E8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Menu Tersedia',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => selectedIndex = 1),
              child: const Text('Lihat Semua', style: TextStyle(color: purple)),
            ),
          ],
        ),
        if (currentMenus.isEmpty)
          const Text('Belum ada menu.')
        else
          ...currentMenus.take(3).map(_menuSummaryCard),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E5F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: darkPurple, size: 25),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPage() {
    final currentMenus = menus;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Kelola Menu',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddMenuDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Atur nama, harga, stok, dan ketersediaan menu.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        if (currentMenus.isEmpty)
          const Center(child: Text('Belum ada menu.'))
        else
          ...currentMenus.map(_menuManagementCard),
      ],
    );
  }

  Widget _menuSummaryCard(Map<String, dynamic> menu) {
    final stock = (menu['stock'] as int?) ?? 0;
    final price = (menu['price'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E5F5)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE9DDF8),
            child: Icon(Icons.restaurant_rounded, color: darkPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['name'] as String? ?? 'Menu',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatRupiah(price),
                  style: const TextStyle(
                    color: Color(0xFFE85D9E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Stok $stock',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _menuManagementCard(Map<String, dynamic> menu) {
    final available = menu['available'] == true;
    final stock = (menu['stock'] as int?) ?? 0;
    final price = (menu['price'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E5F5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DDF8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(canteenIcon, color: darkPurple, size: 28),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu['name'] as String? ?? 'Menu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_formatRupiah(price)),
                    const SizedBox(height: 4),
                    Text('Stok: $stock'),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditMenuDialog(menu);
                  } else if (value == 'delete') {
                    _confirmDeleteMenu(menu);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit menu')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus menu')),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  available ? 'Menu tersedia' : 'Menu tidak tersedia',
                  style: TextStyle(
                    color: available ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: available,
                activeTrackColor: purple,
                onChanged: (value) {
                  final index = _menuIndex(menu);

                  if (index != -1) {
                    menuStore.setAvailability(
                      widget.canteenId,
                      index,
                      value && stock > 0,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Daftar Pesanan',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pantau dan perbarui status pesanan mahasiswa.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        if (orders.isEmpty)
          const Center(child: Text('Belum ada pesanan masuk.'))
        else
          ...orders.map(_orderCard),
      ],
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E5F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: purple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order['code'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const Divider(height: 24),
          Text(
            order['menu'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 5),
          Text('Jumlah: ${order['quantity']}'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _updateOrderStatus(order),
              child: const Text('Perbarui Status'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final Color color = status == 'Selesai'
        ? Colors.green
        : status == 'Diproses'
        ? Colors.orange
        : purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showAddMenuDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama menu'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (contoh: 13000)',
                ),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah stok'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());

              if (name.isEmpty ||
                  price == null ||
                  price <= 0 ||
                  stock == null ||
                  stock < 0) {
                _showMessage('Periksa kembali data menu.');
                return;
              }

              final duplicate = menus.any(
                (item) =>
                    (item['name'] as String).toLowerCase() ==
                    name.toLowerCase(),
              );

              if (duplicate) {
                _showMessage('Nama menu sudah ada di kantin ini.');
                return;
              }

              menuStore.addMenu(widget.canteenId, {
                'name': name,
                'price': price,
                'stock': stock,
                'available': stock > 0,
                'icon': '🍽️',
                'image': '',
              });

              Navigator.pop(dialogContext);
              _showMessage('Menu berhasil ditambahkan.');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
  }

  Future<void> _showEditMenuDialog(Map<String, dynamic> menu) async {
    final nameController = TextEditingController(
      text: menu['name'] as String? ?? '',
    );
    final priceController = TextEditingController(
      text: '${menu['price'] ?? 0}',
    );
    final stockController = TextEditingController(
      text: '${menu['stock'] ?? 0}',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama menu'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah stok'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());

              if (name.isEmpty ||
                  price == null ||
                  price <= 0 ||
                  stock == null ||
                  stock < 0) {
                _showMessage('Data menu belum valid.');
                return;
              }

              final duplicate = menus.any(
                (item) =>
                    (item['name'] as String).toLowerCase() ==
                        name.toLowerCase() &&
                    item['name'] != menu['name'],
              );

              if (duplicate) {
                _showMessage('Nama menu sudah digunakan.');
                return;
              }

              final index = _menuIndex(menu);

              if (index == -1) {
                Navigator.pop(dialogContext);
                _showMessage('Menu tidak ditemukan. Muat ulang halaman.');
                return;
              }

              menuStore.updateMenu(widget.canteenId, index, {
                ...menu,
                'name': name,
                'price': price,
                'stock': stock,
                'available': stock > 0 && menu['available'] == true,
              });

              Navigator.pop(dialogContext);
              _showMessage('Menu berhasil diperbarui.');
            },
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );

    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
  }

  Future<void> _confirmDeleteMenu(Map<String, dynamic> menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Menu?'),
        content: Text('Yakin ingin menghapus ${menu['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final index = _menuIndex(menu);

      if (index != -1) {
        menuStore.deleteMenu(widget.canteenId, index);
        _showMessage('Menu berhasil dihapus.');
      } else {
        _showMessage('Menu tidak ditemukan.');
      }
    }
  }

  Future<void> _updateOrderStatus(Map<String, dynamic> order) async {
    final currentStatus = order['status'] as String;

    final nextStatus = currentStatus == 'Menunggu'
        ? 'Diproses'
        : currentStatus == 'Diproses'
        ? 'Selesai'
        : 'Menunggu';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Perbarui Status'),
        content: Text(
          'Ubah status pesanan ${order['code']} '
          'menjadi "$nextStatus"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Perbarui'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => order['status'] = nextStatus);
      _showMessage('Status pesanan diperbarui: $nextStatus');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }
}
