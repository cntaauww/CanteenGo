import 'package:flutter/material.dart';

import 'data/order_store.dart';

class OrderStatusPage extends StatefulWidget {
  final String orderNumber;

  const OrderStatusPage({super.key, required this.orderNumber});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color lilac = Color(0xFFE9DDF8);
  static const Color background = Color(0xFFF9F7FF);

  final List<String> statuses = const [
    'Menunggu Pembayaran',
    'Menunggu Konfirmasi',
    'Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  Map<String, dynamic>? get order {
    for (final item in OrderStore.orders) {
      if (item['number']?.toString() == widget.orderNumber) {
        return item;
      }
    }
    return null;
  }

  int toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String formatRupiah(int value) {
    final digits = value.toString();
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

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: currentOrder == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Pesanan tidak ditemukan. Silakan kembali dan periksa pesananmu.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _buildOrder(currentOrder),
    );
  }

  Widget _buildOrder(Map<String, dynamic> currentOrder) {
    final currentStatus = currentOrder['status']?.toString() ?? statuses.first;

    final statusIndex = statuses.indexOf(currentStatus);
    final safeIndex = statusIndex < 0 ? 0 : statusIndex;

    final items =
        (currentOrder['items'] as List?)
            ?.whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList() ??
        <Map<String, dynamic>>[];

    final total = toInt(currentOrder['total']);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card(
          child: Row(
            children: [
              _iconBox(Icons.receipt_long),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Pesanan',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentOrder['number']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 23,
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

        const SizedBox(height: 18),

        _card(
          child: Row(
            children: [
              _iconBox(Icons.storefront),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kantin',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentOrder['canteen']?.toString() ?? 'Kantin',
                      style: const TextStyle(
                        fontSize: 17,
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

        const SizedBox(height: 24),

        const Text(
          'Status Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE5FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_dining, color: purple, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStatus,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusDescription(currentStatus),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: darkPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Proses Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 12),

        _card(
          child: Column(
            children: List.generate(statuses.length, (index) {
              return _statusStep(
                title: statuses[index],
                subtitle: _statusDescription(statuses[index]),
                icon: _statusIcon(index),
                active: index <= safeIndex,
                isLast: index == statuses.length - 1,
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 12),

        _card(
          child: Column(
            children: [
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Tidak ada detail menu pada pesanan ini.'),
                ),

              ...items.map((item) {
                final name = item['name']?.toString() ?? 'Menu';
                final quantity = toInt(item['quantity'] ?? item['qty']);
                final price = toInt(item['price']);
                final subtotal = toInt(item['subtotal']) > 0
                    ? toInt(item['subtotal'])
                    : price * quantity;
                final note = item['note']?.toString() ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDF4),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          item['icon']?.toString() ?? '🍽️',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            const SizedBox(height: 4),
                            Text(
                              '${formatRupiah(price)} x $quantity',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (note.trim().isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                'Catatan: $note',
                                style: const TextStyle(
                                  color: purple,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatRupiah(subtotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: purple,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Divider(color: lilac),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                      fontSize: 16,
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
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
            style: OutlinedButton.styleFrom(
              foregroundColor: purple,
              side: const BorderSide(color: purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return 'Silakan membayar kepada pengelola kantin.';
      case 'Menunggu Konfirmasi':
        return 'Pengelola sedang memeriksa pembayaranmu.';
      case 'Diproses':
        return 'Pesananmu sedang disiapkan oleh pengelola kantin.';
      case 'Siap Diambil':
        return 'Pesananmu siap diambil di kantin.';
      case 'Selesai':
        return 'Pesananmu telah selesai. Terima kasih!';
      default:
        return 'Pantau status pesananmu di sini.';
    }
  }

  IconData _statusIcon(int index) {
    switch (index) {
      case 0:
        return Icons.payments_outlined;
      case 1:
        return Icons.verified_outlined;
      case 2:
        return Icons.restaurant;
      case 3:
        return Icons.shopping_bag_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lilac.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: purple, size: 27),
    );
  }

  Widget _statusStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEDE5FF)
                      : const Color(0xFFF2F2F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: active ? purple : Colors.grey),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 25,
                  color: active ? purple.withValues(alpha: 0.4) : lilac,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: active ? darkPurple : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
