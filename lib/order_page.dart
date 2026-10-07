import 'package:flutter/material.dart';

import 'checkout_page.dart';

class OrderPage extends StatelessWidget {
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
          'Pesanan Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: orderedMenus.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 70,
                    color: Color(0xFF9B7DD4),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yuk pilih makanan yang kamu suka!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // KANTIN
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, color: Color(0xFF8B6CC7)),
                      const SizedBox(width: 10),
                      Text(
                        'Kantin $canteenNumber',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // ITEM PESANAN
                ...orderedMenus.map((menu) => _orderCard(menu)),

                const SizedBox(height: 15),

                // TOTAL
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6CC7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CHECKOUT
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
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
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _orderCard(Map<String, dynamic> menu) {
    final int quantity = cart[menu['name']] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
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
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'x$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B6CC7),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
