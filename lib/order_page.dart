import 'package:flutter/material.dart';

import 'checkout_page.dart';
import 'data/order_store.dart';
import 'order_status_page.dart';
import 'services/order_api_service.dart';

class OrderPage extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> menus;
  final int canteenNumber;

  const OrderPage({
    super.key,
    required this.cart,
    required this.menus,
    required this.canteenNumber,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const Color pink = Color(0xFFF4A6C5);
  static const Color lilac = Color(0xFFE9DDF8);
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFFFF8FC);

  final Map<String, String> notes = {};
  final Map<String, TextEditingController> controllers = {};

  bool isLoading = true;
  String? loadError;
  List<Map<String, dynamic>> serverOrders = [];

  static const Set<String> activeStatuses = {
    'menunggu_pembayaran',
    'menunggu_konfirmasi',
    'diproses',
    'siap_diambil',
  };

  @override
  void initState() {
    super.initState();
    OrderStore.revision.addListener(refreshOrders);
    loadOrders();
  }

  @override
  void dispose() {
    OrderStore.revision.removeListener(refreshOrders);
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void refreshOrders() {
    if (mounted) setState(() {});
  }

  Future<void> loadOrders() async {
    try {
      final orders = await OrderApiService.instance.getOrders();
      if (!mounted) return;

      setState(() {
        serverOrders = orders;
        loadError = null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadError = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  TextEditingController getController(String name) {
    return controllers.putIfAbsent(name, () => TextEditingController());
  }

  int parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is num) return price.round();

    final value = price.toString().trim();

    // Harga API Laravel seperti "15000.00" harus dibaca sebagai 15000.
    final decimalValue = double.tryParse(value);
    if (decimalValue != null) return decimalValue.round();

    // Harga tampilan seperti "Rp15.000".
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String formatRupiah(int number) {
    final value = number.toString();
    final result = StringBuffer();
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      result.write(value[i]);
      count++;
      if (count == 3 && i != 0) {
        result.write('.');
        count = 0;
      }
    }
    return 'Rp${result.toString().split('').reversed.join()}';
  }

  String readableStatus(dynamic rawStatus) {
    switch (rawStatus?.toString().toLowerCase()) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'diproses':
        return 'Diproses';
      case 'siap_diambil':
        return 'Siap Diambil';
      case 'selesai':
        return 'Selesai';
      default:
        return rawStatus?.toString() ?? 'Status tidak diketahui';
    }
  }

  Map<String, dynamic>? get activeOrder {
    final orders = serverOrders.where((order) {
      final canteen = int.tryParse(order['nomor_kantin']?.toString() ?? '');
      final status = order['status_pesanan']?.toString().toLowerCase();

      return canteen == widget.canteenNumber && activeStatuses.contains(status);
    }).toList();

    if (orders.isEmpty) return null;

    // Pesanan terbaru berada di urutan pertama dari API Laravel.
    return orders.first;
  }

  List<Map<String, dynamic>> get cartItems {
    return widget.menus
        .where((menu) => (widget.cart[menu['name']] ?? 0) > 0)
        .toList();
  }

  int calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (final menu in items) {
      total += parsePrice(menu['price']) * (widget.cart[menu['name']] ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Keranjang aktif harus diprioritaskan. Pesanan lama dari server
    // hanya ditampilkan jika keranjang memang kosong.
    final items = cartItems;

    if (items.isEmpty && isLoading) {
      return Scaffold(
        backgroundColor: background,
        appBar: buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: purple)),
      );
    }

    if (items.isEmpty && loadError != null) {
      return Scaffold(
        backgroundColor: background,
        appBar: buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 55, color: purple),
                const SizedBox(height: 12),
                const Text(
                  'Pesanan belum bisa dimuat',
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      loadError = null;
                    });
                    loadOrders();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Tampilkan pesanan aktif sebelumnya hanya jika tidak ada item baru
    // di keranjang mahasiswa.
    if (items.isEmpty) {
      final order = activeOrder;
      if (order != null) {
        return buildExistingOrder(order);
      }

      return Scaffold(
        backgroundColor: background,
        appBar: buildAppBar(),
        body: buildEmptyCart(),
      );
    }

    final total = calculateTotal(items);
    final totalItems = items.fold<int>(
      0,
      (sum, menu) => sum + (widget.cart[menu['name']] ?? 0),
    );

    return Scaffold(
      backgroundColor: background,
      appBar: buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          buildHeader(totalItems),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: purple),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Daftar Pesanan',
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$totalItems item',
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          buildCanteenCard(),
          ...items.map(buildOrderCard),
          const SizedBox(height: 10),
          buildTotalCard(total),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      cart: widget.cart,
                      menus: widget.menus,
                      canteenNumber: widget.canteenNumber,
                      notes: Map<String, String>.from(notes),
                    ),
                  ),
                ).then((_) => loadOrders());
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Lanjut ke Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: pink, size: 16),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Periksa pesananmu sebelum checkout, ya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Pesanan Saya',
        style: TextStyle(
          color: darkPurple,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      iconTheme: const IconThemeData(color: darkPurple),
    );
  }

  Widget buildExistingOrder(Map<String, dynamic> order) {
    final orderNumber = order['kode_pesanan']?.toString() ?? '-';
    final status = readableStatus(order['status_pesanan']);
    final items = (order['items'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final canteen = order['nomor_kantin']?.toString() ?? '-';
    final total = parsePrice(order['total_harga']);

    return Scaffold(
      backgroundColor: background,
      appBar: buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBE0EC), Color(0xFFEDE4FF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long_rounded, color: purple, size: 48),
                SizedBox(height: 12),
                Text(
                  'Pesanan kamu sudah tercatat!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Kamu tidak perlu checkout ulang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: darkPurple),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: lilac),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kode Pesanan',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Status Pesanan',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: lilac,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: purple),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan • Kantin $canteen',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 14),
                ...items.map((item) {
                  final name =
                      item['nama_menu']?.toString() ??
                      item['menu']?['nama_menu']?.toString() ??
                      'Menu';
                  final quantity = parsePrice(item['jumlah']);
                  final subtotal = parsePrice(item['subtotal']);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$name x$quantity',
                            style: const TextStyle(color: darkPurple),
                          ),
                        ),
                        Text(
                          formatRupiah(subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: purple,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pembayaran dilakukan di luar aplikasi.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderStatusPage(orderNumber: orderNumber),
                  ),
                ).then((_) => loadOrders());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Lihat Status Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Kembali ke Menu'),
            style: OutlinedButton.styleFrom(
              foregroundColor: purple,
              side: const BorderSide(color: lilac),
              padding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(int totalItems) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBE0EC), Color(0xFFEDE4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: purple,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hampir selesai! 💗',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$totalItems item siap dipesan',
                  style: const TextStyle(fontSize: 13, color: darkPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCanteenCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lilac,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.storefront_rounded, color: purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kantin ${widget.canteenNumber}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Pesanan dari kantin pilihanmu',
                  style: TextStyle(fontSize: 12, color: darkPurple),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: purple),
        ],
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> menu) {
    final name = menu['name'].toString();
    final quantity = widget.cart[name] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lilac),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDF4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    menu['icon']?.toString() ?? '🍽️',
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      menu['price'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: purple,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Subtotal: ${formatRupiah(parsePrice(menu['price']) * quantity)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: lilac,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x$quantity',
                  style: const TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Catatan untuk menu ini (opsional)',
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: getController(name),
            maxLines: 2,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) {
              if (value.trim().isEmpty) {
                notes.remove(name);
              } else {
                notes[name] = value.trim();
              }
            },
            decoration: InputDecoration(
              hintText: 'Contoh: jangan terlalu pedas...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: background,
              counterStyle: const TextStyle(fontSize: 10),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: lilac),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: lilac),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: pink, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTotalCard(int total) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lilac),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: purple),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Ringkasan Belanja',
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Divider(color: lilac),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Pembayaran',
                  style: TextStyle(color: darkPurple, fontSize: 14),
                ),
              ),
              Text(
                formatRupiah(total),
                style: const TextStyle(
                  color: purple,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pembayaran dilakukan di luar aplikasi.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 85, color: purple),
            const SizedBox(height: 23),
            const Text(
              'Keranjangmu masih kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkPurple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Yuk, pilih makanan dan minuman favoritmu dulu!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text(
                  'Pilih Menu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
