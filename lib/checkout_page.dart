import 'package:flutter/material.dart';

import 'mahasiswa_login_page.dart';
import 'order_status_page.dart';
import 'services/auth_service.dart';
import 'services/menu_api_service.dart';
import 'services/order_api_service.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> menus;
  final int canteenNumber;
  final Map<String, String> notes;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.menus,
    required this.canteenNumber,
    required this.notes,
  });

  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color lilac = Color(0xFFE9DDF8);
  static const Color background = Color(0xFFFFF8FC);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color purple = CheckoutPage.purple;
  static const Color darkPurple = CheckoutPage.darkPurple;
  static const Color lilac = CheckoutPage.lilac;
  static const Color background = CheckoutPage.background;

  String selectedServingType = 'dine_in';
  bool isCreatingOrder = false;

  // Membaca harga dari API (15000.00), angka biasa (15000),
  // atau harga tampilan (Rp15.000).
  int getPrice(Map<String, dynamic> menu) {
    final dynamic rawPrice = menu['price'];

    if (rawPrice == null) return 0;
    if (rawPrice is num) return rawPrice.round();

    final value = rawPrice.toString().trim();

    final decimalValue = double.tryParse(value);
    if (decimalValue != null) {
      return decimalValue.round();
    }

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

  int calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;

    for (final menu in items) {
      total += getPrice(menu) * (widget.cart[menu['name']] ?? 0);
    }

    return total;
  }

  String get servingLabel {
    return selectedServingType == 'takeaway'
        ? 'Takeaway / Bungkus'
        : 'Makan di Tempat';
  }

  Future<void> createOrder(BuildContext context) async {
    if (isCreatingOrder) return;

    // Periksa login terlebih dahulu.
    final token = await AuthService.instance.getToken();

    if (!context.mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MahasiswaLoginPage(
            cart: Map<String, int>.from(widget.cart),
            menus: List<Map<String, dynamic>>.from(widget.menus),
            canteenNumber: widget.canteenNumber,
            notes: Map<String, String>.from(widget.notes),
          ),
        ),
      );
      return;
    }

    final items = widget.menus
        .where((menu) => (widget.cart[menu['name']] ?? 0) > 0)
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang pesanan masih kosong.')),
      );
      return;
    }

    setState(() {
      isCreatingOrder = true;
    });

    try {
      // Cart entries can outlive the menu snapshot passed to this page.
      // Resolve IDs from Laravel so stale/local menu data cannot block checkout.
      final serverMenus = await MenuApiService().getMenus(
        canteenNumber: widget.canteenNumber,
      );

      if (!context.mounted) return;

      final serverMenuIds = <String, int>{};
      for (final serverMenu in serverMenus) {
        final name = serverMenu['nama_menu']?.toString().trim() ?? '';
        final menuId = int.tryParse(serverMenu['id']?.toString() ?? '');

        if (name.isNotEmpty && menuId != null && menuId > 0) {
          serverMenuIds[name.toLowerCase()] = menuId;
        }
      }

      final apiItems = <Map<String, int>>[];
      for (final menu in items) {
        final name = menu['name'].toString().trim();
        final menuId = serverMenuIds[name.toLowerCase()];
        final quantity = widget.cart[menu['name']] ?? 0;

        if (menuId == null) {
          throw Exception(
            'Menu "$name" tidak ditemukan di server. '
            'Kembali ke halaman menu, muat ulang, lalu coba lagi.',
          );
        }

        if (quantity > 0) {
          apiItems.add({'menu_id': menuId, 'jumlah': quantity});
        }
      }

      if (apiItems.isEmpty) {
        throw Exception('Tidak ada menu valid untuk dipesan.');
      }

      // Gabungkan catatan masing-masing menu menjadi satu catatan pesanan.
      final notesList = <String>[];

      for (final menu in items) {
        final name = menu['name'].toString();
        final note = widget.notes[name]?.trim() ?? '';

        if (note.isNotEmpty) {
          notesList.add('$name: $note');
        }
      }

      final combinedNotes = notesList.isEmpty ? null : notesList.join('\n');
      final orderData = await OrderApiService.instance.createOrder(
        canteenNumber: widget.canteenNumber,
        servingType: selectedServingType,
        items: apiItems,
        notes: combinedNotes,
      );

      if (!context.mounted) return;

      final orderNumber = orderData['kode_pesanan']?.toString();

      if (orderNumber == null || orderNumber.isEmpty) {
        throw Exception('Kode pesanan dari server tidak ditemukan.');
      }

      // Simpan salinan detail pesanan untuk halaman sukses.
      final orderedCart = Map<String, int>.from(widget.cart);

      // Kosongkan keranjang aktif agar pesanan yang sudah dibuat
      // tidak muncul lagi sebagai item keranjang baru.
      widget.cart.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            cart: orderedCart,
            menus: widget.menus,
            canteenNumber: widget.canteenNumber,
            notes: Map<String, String>.from(widget.notes),
            orderNumber: orderNumber,
            servingType: selectedServingType,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCreatingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.menus
        .where((menu) => (widget.cart[menu['name']] ?? 0) > 0)
        .toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                buildCanteenCard(),
                const SizedBox(height: 22),
                const Text(
                  'Jenis Penyajian',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 12),
                buildServingOption(
                  value: 'dine_in',
                  title: 'Makan di Tempat',
                  description: 'Makan di area kantin.',
                  icon: Icons.restaurant,
                ),
                const SizedBox(height: 10),
                buildServingOption(
                  value: 'takeaway',
                  title: 'Takeaway / Bungkus',
                  description: 'Makanan disiapkan dalam kemasan bungkus.',
                  icon: Icons.shopping_bag_outlined,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.map(buildCheckoutItem),
                const SizedBox(height: 5),
                buildTotalCard(calculateTotal(items)),
                const SizedBox(height: 25),
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 12),
                buildPaymentCard(),
                const SizedBox(height: 20),
                buildStatusInfo(),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isCreatingOrder
                        ? null
                        : () => createOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: lilac,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isCreatingOrder
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Buat Pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget buildServingOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final selected = selectedServingType == value;

    return InkWell(
      onTap: isCreatingOrder
          ? null
          : () {
              setState(() {
                selectedServingType = value;
              });
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? purple : lilac,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: lilac,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: purple, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? purple : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCanteenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: lilac,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront, color: purple),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kantin',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 3),
              Text(
                'Kantin ${widget.canteenNumber}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCheckoutItem(Map<String, dynamic> menu) {
    final name = menu['name'].toString();
    final quantity = widget.cart[name] ?? 0;
    final subtotal = getPrice(menu) * quantity;
    final note = widget.notes[name]?.trim() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lilac),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                menu['icon']?.toString() ?? '🍽️',
                style: const TextStyle(fontSize: 28),
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
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${formatRupiah(getPrice(menu))} x $quantity',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Catatan: $note',
                      style: const TextStyle(
                        fontSize: 12,
                        color: darkPurple,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(subtotal),
            style: const TextStyle(fontWeight: FontWeight.bold, color: purple),
          ),
        ],
      ),
    );
  }

  Widget buildTotalCard(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pesanan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          Text(
            formatRupiah(total),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lilac,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.payments_outlined, color: purple, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran di luar aplikasi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Silakan melakukan pembayaran langsung di kantin '
                  'atau transfer ke rekening penjual. Jika transfer, '
                  'tunjukkan bukti transfer kepada pengelola kantin.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD875)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFB8860B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Setelah pesanan dibuat, statusnya menjadi '
              'Menunggu Pembayaran. Pengelola kantin akan '
              'memeriksa dan mengonfirmasi pembayaran sebelum '
              'pesanan diproses.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSuccessPage extends StatelessWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> menus;
  final int canteenNumber;
  final Map<String, String> notes;
  final String orderNumber;
  final String servingType;

  const OrderSuccessPage({
    super.key,
    required this.cart,
    required this.menus,
    required this.canteenNumber,
    required this.notes,
    required this.orderNumber,
    required this.servingType,
  });

  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFFFF8FC);

  String get servingLabel {
    return servingType == 'takeaway' ? 'Takeaway / Bungkus' : 'Makan di Tempat';
  }

  IconData get servingIcon {
    return servingType == 'takeaway'
        ? Icons.shopping_bag_outlined
        : Icons.restaurant;
  }

  int getPrice(Map<String, dynamic> menu) {
    final dynamic rawPrice = menu['price'];

    if (rawPrice == null) return 0;
    if (rawPrice is num) return rawPrice.round();

    final value = rawPrice.toString().trim();
    final decimalValue = double.tryParse(value);

    if (decimalValue != null) {
      return decimalValue.round();
    }

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

  int calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;

    for (final menu in items) {
      total += getPrice(menu) * (cart[menu['name']] ?? 0);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final items = menus.where((menu) => (cart[menu['name']] ?? 0) > 0).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pesanan Berhasil',
          style: TextStyle(fontWeight: FontWeight.bold, color: darkPurple),
        ),
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFEDE5FF),
                  child: Icon(Icons.check, size: 48, color: purple),
                ),
                SizedBox(height: 18),
                Text(
                  'Pesanan Berhasil Dibuat!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Pesanan kamu sudah tercatat di sistem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE5FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nomor Pesanan',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9DDF8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(servingIcon, color: purple, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Penyajian',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        servingLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE5FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.payments_outlined, color: purple, size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pembayaran',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Pembayaran di luar aplikasi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Silakan membayar langsung di kantin atau '
                        'transfer kepada penjual. Jika transfer, '
                        'tunjukkan bukti transfer kepada pengelola.',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD875)),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFFB8860B), size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Pesanan',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Menunggu Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB8860B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront, color: purple),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kantin',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Kantin $canteenNumber',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 15),
                ...items.map((menu) {
                  final name = menu['name'].toString();
                  final quantity = cart[name] ?? 0;
                  final note = notes[name]?.trim() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu['icon']?.toString() ?? '🍽️',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$name x$quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: darkPurple,
                                ),
                              ),
                              if (note.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  'Catatan: $note',
                                  style: const TextStyle(
                                    color: purple,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRupiah(getPrice(menu) * quantity),
                          style: const TextStyle(
                            color: purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    Text(
                      formatRupiah(calculateTotal(items)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderStatusPage(orderNumber: orderNumber),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Lihat Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
