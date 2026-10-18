import 'package:flutter/material.dart';

import '../data/order_store.dart';
import 'detail_order_page.dart';

class OrderMasukPage extends StatefulWidget {
  final int canteenNumber;

  const OrderMasukPage({super.key, this.canteenNumber = 1});

  @override
  State<OrderMasukPage> createState() => _OrderMasukPageState();
}

class _OrderMasukPageState extends State<OrderMasukPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFF9F7FF);

  String formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    final digits = number.toString();
    final result = StringBuffer();
    int count = 0;

    for (int i = digits.length - 1; i >= 0; i--) {
      result.write(digits[i]);
      count++;

      if (count == 3 && i != 0) {
        result.write('.');
        count = 0;
      }
    }

    return 'Rp${result.toString().split('').reversed.join()}';
  }

  Future<void> openOrder(Map<String, dynamic> order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailOrderPage(order: order)),
    );

    if (!mounted) return;

    // Perbarui daftar setelah kembali dari detail pesanan.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderStore.orders.where((order) {
      final number = int.tryParse(order['canteenNumber']?.toString() ?? '');

      return number == widget.canteenNumber;
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pesanan Kantin ${widget.canteenNumber}',
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 65,
                      color: purple,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Belum Ada Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pesanan untuk Kantin ${widget.canteenNumber} '
                      'akan muncul di halaman ini.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = (order['items'] as List<dynamic>?) ?? [];

                final hasNotes = items.any((item) {
                  if (item is! Map) return false;
                  return (item['note']?.toString() ?? '').trim().isNotEmpty;
                });

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFEDE5FF)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEDE5FF),
                      child: Icon(Icons.receipt_long, color: purple),
                    ),
                    title: Text(
                      order['number']?.toString() ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['student']?.toString() ?? 'Mahasiswa'),
                          const SizedBox(height: 5),
                          Text(
                            order['status']?.toString() ?? '-',
                            style: const TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (hasNotes) ...[
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: 15,
                                  color: purple,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ada catatan makanan',
                                  style: TextStyle(
                                    color: purple,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            'Total: ${formatRupiah(order['total'])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: purple),
                    onTap: () => openOrder(order),
                  ),
                );
              },
            ),
    );
  }
}
