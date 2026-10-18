import 'package:flutter/material.dart';

import 'data/order_store.dart';
import 'order_status_page.dart';

class CheckoutPage extends StatelessWidget {
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

  int getPrice(Map<String, dynamic> menu) {
    final digits = menu['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
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

  void createOrder(BuildContext context) {
    final items = menus.where((menu) => (cart[menu['name']] ?? 0) > 0).toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang pesanan masih kosong.')),
      );
      return;
    }

    final selectedItems = items.map((menu) {
      final name = menu['name'].toString();
      final quantity = cart[name] ?? 0;
      final price = getPrice(menu);

      return <String, dynamic>{
        'name': name,
        'quantity': quantity,
        'price': price,
        'subtotal': price * quantity,
        'note': notes[name]?.trim() ?? '',
        'icon': menu['icon']?.toString() ?? '🍽️',
      };
    }).toList();

    final order = OrderStore.addOrder(
      canteenNumber: canteenNumber,
      items: selectedItems,
      total: calculateTotal(items),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessPage(
          cart: cart,
          menus: menus,
          canteenNumber: canteenNumber,
          notes: Map<String, String>.from(notes),
          orderNumber: order['number'].toString(),
        ),
      ),
    );
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
                    onPressed: () => createOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
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
    );
  }

  Widget buildCheckoutItem(Map<String, dynamic> menu) {
    final name = menu['name'].toString();
    final quantity = cart[name] ?? 0;
    final subtotal = getPrice(menu) * quantity;
    final note = notes[name]?.trim() ?? '';

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
                  '${menu['price']} x $quantity',
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

  const OrderSuccessPage({
    super.key,
    required this.cart,
    required this.menus,
    required this.canteenNumber,
    required this.notes,
    required this.orderNumber,
  });

  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFFFF8FC);

  int getPrice(Map<String, dynamic> menu) {
    final digits = menu['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
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
                        'Silakan melakukan pembayaran kepada '
                        'pengelola kantin.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Jika transfer, tunjukkan bukti transfer '
                        'kepada pengelola kantin.',
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
