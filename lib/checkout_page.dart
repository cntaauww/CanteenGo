import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> menus;
  final int canteenNumber;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.menus,
    required this.canteenNumber,
  });

  @override
  Widget build(BuildContext context) {
    final orderedMenus = menus
        .where((menu) => (cart[menu['name']] ?? 0) > 0)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7FF),
        elevation: 0,
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: orderedMenus.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // INFORMASI KANTIN
                  // =========================

                  Container(
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
                            color: const Color(0xFFEDE5FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Color(0xFF9B7DD4),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kantin',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              'Kantin $canteenNumber',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =========================
                  // DETAIL PESANAN
                  // =========================
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  ...orderedMenus.map((menu) => _checkoutItem(menu)),

                  const SizedBox(height: 15),

                  // =========================
                  // TOTAL PESANAN
                  // =========================
                  Container(
                    width: double.infinity,
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
                          ),
                        ),

                        Text(
                          _calculateTotal(orderedMenus),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B6CC7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // METODE PEMBAYARAN
                  // =========================
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE5FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            color: Color(0xFF8B6CC7),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pembayaran di luar aplikasi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3B63),
                                ),
                              ),

                              SizedBox(height: 7),

                              Text(
                                'Silakan melakukan pembayaran '
                                'langsung di kantin atau transfer '
                                'ke rekening penjual. Jika melakukan '
                                'transfer, tunjukkan bukti transfer '
                                'kepada pengelola kantin.',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // INFORMASI STATUS
                  // =========================
                  Container(
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
                            'Setelah pesanan dibuat, status '
                            'pesanan akan menjadi Menunggu Pembayaran. '
                            'Pengelola kantin akan mengonfirmasi '
                            'pembayaran sebelum pesanan diproses.',
                            style: TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // TOMBOL BUAT PESANAN
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSuccessPage(
                              cart: cart,
                              menus: menus,
                              canteenNumber: canteenNumber,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B7DD4),
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
            ),
    );
  }

  // =====================================================
  // ITEM PESANAN
  // =====================================================

  Widget _checkoutItem(Map<String, dynamic> menu) {
    final int quantity = cart[menu['name']] ?? 0;

    final String priceString = menu['price'].toString();

    final int price = int.parse(
      priceString.replaceAll('Rp', '').replaceAll('.', ''),
    );

    final int subtotal = price * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(menu['icon'], style: const TextStyle(fontSize: 28)),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  '${menu['price']} x $quantity',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          Text(
            'Rp${_formatNumber(subtotal)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B6CC7),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // HITUNG TOTAL
  // =====================================================

  String _calculateTotal(List<Map<String, dynamic>> orderedMenus) {
    int total = 0;

    for (final menu in orderedMenus) {
      final int quantity = cart[menu['name']] ?? 0;

      final String priceString = menu['price'].toString();

      final int price = int.parse(
        priceString.replaceAll('Rp', '').replaceAll('.', ''),
      );

      total += price * quantity;
    }

    return 'Rp${_formatNumber(total)}';
  }

  // =====================================================
  // FORMAT ANGKA
  // =====================================================

  String _formatNumber(int number) {
    final String numberString = number.toString();

    final StringBuffer result = StringBuffer();

    int count = 0;

    for (int i = numberString.length - 1; i >= 0; i--) {
      result.write(numberString[i]);

      count++;

      if (count == 3 && i != 0) {
        result.write('.');
        count = 0;
      }
    }

    return result.toString().split('').reversed.join();
  }
}

// =========================================================
// HALAMAN PESANAN BERHASIL
// =========================================================

class OrderSuccessPage extends StatelessWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> menus;
  final int canteenNumber;

  const OrderSuccessPage({
    super.key,
    required this.cart,
    required this.menus,
    required this.canteenNumber,
  });

  @override
  Widget build(BuildContext context) {
    final orderedMenus = menus
        .where((menu) => (cart[menu['name']] ?? 0) > 0)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7FF),
        elevation: 0,
        title: const Text(
          'Pesanan Berhasil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =========================
            // PESANAN BERHASIL
            // =========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,

                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE5FF),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.check,
                      size: 48,
                      color: Color(0xFF9B7DD4),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Pesanan Berhasil Dibuat! 🎉',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3B63),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Pesanan kamu sudah tercatat di sistem.',
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // INFORMASI PEMBAYARAN
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFFEDE5FF),
                borderRadius: BorderRadius.circular(18),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF8B6CC7),
                    size: 30,
                  ),

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
                          'Silakan melakukan pembayaran '
                          'kepada pengelola kantin.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A3B63),
                          ),
                        ),

                        SizedBox(height: 7),

                        Text(
                          'Jika melakukan transfer, '
                          'tunjukkan bukti transfer '
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

            // =========================
            // STATUS PESANAN
            // =========================
            Container(
              width: double.infinity,
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

            // =========================
            // KANTIN
            // =========================
            Container(
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
                      color: const Color(0xFFEDE5FF),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.storefront,
                      color: Color(0xFF9B7DD4),
                    ),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // DETAIL PESANAN
            // =========================
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
                    'Pesanan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ...orderedMenus.map((menu) {
                    final int quantity = cart[menu['name']] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: Row(
                        children: [
                          Text(
                            menu['icon'],
                            style: const TextStyle(fontSize: 28),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              '${menu['name']} x$quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Text(
                            menu['price'],
                            style: const TextStyle(
                              color: Color(0xFF8B6CC7),
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
                        ),
                      ),

                      Text(
                        _calculateTotal(orderedMenus),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6CC7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // LIHAT PESANAN
            // =========================
            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B7DD4),
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
      ),
    );
  }

  // =====================================================
  // HITUNG TOTAL
  // =====================================================

  String _calculateTotal(List<Map<String, dynamic>> orderedMenus) {
    int total = 0;

    for (final menu in orderedMenus) {
      final int quantity = cart[menu['name']] ?? 0;

      final String priceString = menu['price'].toString();

      final int price = int.parse(
        priceString.replaceAll('Rp', '').replaceAll('.', ''),
      );

      total += price * quantity;
    }

    return 'Rp${_formatNumber(total)}';
  }

  // =====================================================
  // FORMAT ANGKA
  // =====================================================

  String _formatNumber(int number) {
    final String numberString = number.toString();

    final StringBuffer result = StringBuffer();

    int count = 0;

    for (int i = numberString.length - 1; i >= 0; i--) {
      result.write(numberString[i]);

      count++;

      if (count == 3 && i != 0) {
        result.write('.');
        count = 0;
      }
    }

    return result.toString().split('').reversed.join();
  }
}
