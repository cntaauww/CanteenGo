import 'package:flutter/material.dart';

import '../data/order_store.dart';

class DetailOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const DetailOrderPage({super.key, required this.order});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  late String status;

  final List<String> statusOptions = [
    'Menunggu Pembayaran',
    'Menunggu Konfirmasi',
    'Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    status = widget.order['status']?.toString() ?? 'Menunggu Pembayaran';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final items = (order['items'] as List<dynamic>?) ?? [];

    final int total = int.tryParse(order['total']?.toString() ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
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
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Detail Pesanan Mahasiswa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order['number']?.toString() ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Informasi Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow('Nomor Pesanan', order['number']?.toString() ?? '-'),

            _infoRow('Kantin', order['canteen']?.toString() ?? '-'),

            _infoRow('Jenis Pesanan', order['servingType']?.toString() ?? '-'),

            _infoRow('Total Pembayaran', 'Rp ${total.toString()}'),

            const SizedBox(height: 24),

            const Text(
              'Menu yang Dipesan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (items.isEmpty)
              const Text('Tidak ada detail menu.')
            else
              ...items.map((item) {
                final menu = item as Map<String, dynamic>;

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

                final int harga =
                    int.tryParse(
                      menu['price']?.toString() ??
                          menu['harga']?.toString() ??
                          '0',
                    ) ??
                    0;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.restaurant,
                      color: Colors.deepPurple,
                    ),
                    title: Text(nama),
                    subtitle: Text('Jumlah: $jumlah'),
                    trailing: Text('Rp ${(harga * jumlah).toString()}'),
                  ),
                );
              }),

            const SizedBox(height: 24),

            const Text(
              'Status Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: statusOptions.contains(status)
                  ? status
                  : statusOptions.first,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pilih Status',
                prefixIcon: Icon(Icons.sync),
              ),
              items: statusOptions.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    status = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final orderNumber = order['number']?.toString() ?? '';

                  if (orderNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor pesanan tidak ditemukan.'),
                      ),
                    );
                    return;
                  }

                  OrderStore.updateStatus(
                    orderNumber: orderNumber,
                    status: status,
                  );

                  setState(() {
                    order['status'] = status;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status diperbarui menjadi: $status'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const Text(': '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
