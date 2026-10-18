import 'package:flutter/material.dart';

class DetailOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const DetailOrderPage({super.key, required this.order});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  late String status;

  final List<String> statuses = [
    'Menunggu Pembayaran',
    'Menunggu Konfirmasi',
    'Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFF9F7FF);

  @override
  void initState() {
    super.initState();

    final currentStatus = widget.order['status']?.toString() ?? statuses.first;

    status = statuses.contains(currentStatus) ? currentStatus : statuses.first;
  }

  int toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String formatRupiah(dynamic value) {
    final digits = toInt(value).toString();
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
    final items = (widget.order['items'] as List<dynamic>?) ?? [];

    final total = toInt(widget.order['total']);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: darkPurple),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE5FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nomor Pesanan'),
                const SizedBox(height: 6),
                Text(
                  widget.order['number']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pemesan: ${widget.order['student']?.toString() ?? 'Mahasiswa'}',
                ),
                Text('Kantin: ${widget.order['canteen']?.toString() ?? '-'}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rincian Makanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 12),

          ...items.whereType<Map>().map((item) {
            final name = item['name']?.toString() ?? 'Menu';

            // Mendukung data lama (qty) dan data baru (quantity).
            final qty = toInt(item['quantity'] ?? item['qty']);
            final price = toInt(item['price']);
            final subtotal = toInt(item['subtotal'] ?? price * qty);
            final note = item['note']?.toString().trim() ?? '';

            return Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFEDE5FF)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['icon']?.toString() ?? '🍽️',
                      style: const TextStyle(fontSize: 28),
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
                          const SizedBox(height: 5),
                          Text(
                            '$qty × ${formatRupiah(price)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (note.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Catatan: $note',
                                style: const TextStyle(
                                  color: darkPurple,
                                  fontSize: 12,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: purple,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pesanan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formatRupiah(total),
                  style: const TextStyle(
                    fontSize: 18,
                    color: purple,
                    fontWeight: FontWeight.bold,
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: status,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pilih status',
                border: OutlineInputBorder(),
              ),
              items: statuses.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    status = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                setState(() {
                  widget.order['status'] = status;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status diperbarui menjadi: $status')),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Simpan Status'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Status disimpan sementara di memori aplikasi '
            'dan belum tersimpan ke database.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
