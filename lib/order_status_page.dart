import 'package:flutter/material.dart';

import '../data/order_store.dart';

class OrderStatusPage extends StatefulWidget {
  final String orderNumber;

  const OrderStatusPage({super.key, required this.orderNumber});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  final List<String> statusSteps = [
    'Menunggu Pembayaran',
    'Menunggu Konfirmasi',
    'Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    OrderStore.revision.addListener(_refreshStatus);
  }

  @override
  void dispose() {
    OrderStore.revision.removeListener(_refreshStatus);
    super.dispose();
  }

  void _refreshStatus() {
    if (!mounted) return;

    setState(() {});
  }

  Map<String, dynamic>? get order {
    return OrderStore.getOrderByNumber(widget.orderNumber);
  }

  int _statusIndex(String status) {
    final index = statusSteps.indexOf(status);
    return index < 0 ? 0 : index;
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return 'Silakan lakukan pembayaran kepada pengelola kantin.';
      case 'Menunggu Konfirmasi':
        return 'Pesananmu sedang menunggu konfirmasi pembayaran.';
      case 'Diproses':
        return 'Pesananmu sedang disiapkan oleh pengelola kantin.';
      case 'Siap Diambil':
        return 'Pesananmu siap diambil di kantin.';
      case 'Selesai':
        return 'Pesananmu telah selesai. Terima kasih!';
      default:
        return 'Status pesanan belum tersedia.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;

    if (currentOrder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Status Pesanan'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Pesanan tidak ditemukan. Silakan kembali '
              'dan periksa nomor pesananmu.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final String currentStatus =
        currentOrder['status']?.toString() ?? 'Menunggu Pembayaran';

    final int activeIndex = _statusIndex(currentStatus);

    final int total =
        int.tryParse(currentOrder['total']?.toString() ?? '0') ?? 0;

    final List<dynamic> items = (currentOrder['items'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pesanan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pesanan Berhasil Dibuat',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nomor pesanan kamu:',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentOrder['number']?.toString() ?? '-',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Saat Ini',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStatus,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_statusDescription(currentStatus)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Perjalanan Pesanan',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            ...List.generate(statusSteps.length, (index) {
              final bool isDone = index <= activeIndex;
              final bool isCurrent = index == activeIndex;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                          ),
                          child: Icon(
                            isDone ? Icons.check : Icons.circle_outlined,
                            color: isDone ? Colors.white : Colors.grey,
                            size: 18,
                          ),
                        ),
                        if (index != statusSteps.length - 1)
                          Container(
                            width: 2,
                            height: 42,
                            color: index < activeIndex
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusSteps[index],
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isDone
                                  ? Colors.deepPurple
                                  : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          if (isCurrent)
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                'Status pesanan saat ini',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 8),

            const Text(
              'Rincian Pesanan',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _detailRow('Kantin', currentOrder['canteen']?.toString() ?? '-'),

            _detailRow(
              'Jenis Pesanan',
              currentOrder['servingType']?.toString() ?? '-',
            ),

            _detailRow('Total', 'Rp ${total.toString()}'),

            const SizedBox(height: 12),

            const Text('Menu:', style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            if (items.isEmpty)
              const Text('Tidak ada rincian menu.')
            else
              ...items.map((item) {
                final Map<String, dynamic> menu = Map<String, dynamic>.from(
                  item as Map,
                );

                final String nama =
                    menu['name']?.toString() ??
                    menu['nama']?.toString() ??
                    'Menu';

                final int jumlah =
                    int.tryParse(
                      menu['quantity']?.toString() ??
                          menu['jumlah']?.toString() ??
                          '1',
                    ) ??
                    1;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(child: Text(nama)),
                      Text('x$jumlah'),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Perbarui Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
