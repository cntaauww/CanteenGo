import 'package:flutter/material.dart';

import '../services/order_api_service.dart';
import 'detail_order_page.dart';

class OrderMasukPage extends StatefulWidget {
  final int canteenNumber;
  final bool embedded;
  final ValueChanged<int>? onOrdersLoaded;

  const OrderMasukPage({
    super.key,
    this.canteenNumber = 1,
    this.embedded = false,
    this.onOrdersLoaded,
  });

  @override
  State<OrderMasukPage> createState() => _OrderMasukPageState();
}

class _OrderMasukPageState extends State<OrderMasukPage> {
  static const Color purple = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF4A3B63);
  static const Color background = Color(0xFFF9F7FF);

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // Mengubah status dari Laravel menjadi tulisan untuk tampilan.
  String formatStatus(dynamic value) {
    switch (value?.toString()) {
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
        return value?.toString() ?? '-';
    }
  }

  String formatRupiah(dynamic value) {
    final number = _parseAmount(value);
    final digits = number.toInt().toString();
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

  int _parseAmount(dynamic value) {
    if (value is num) return value.round();

    final text = value?.toString().trim() ?? '';
    final parsed = double.tryParse(text);
    if (parsed != null) return parsed.round();

    return int.tryParse(text.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }

  // Mengubah format data Laravel agar sesuai dengan halaman detail.
  Map<String, dynamic> convertOrder(Map<String, dynamic> order) {
    final user = order['user'] is Map
        ? Map<String, dynamic>.from(order['user'])
        : <String, dynamic>{};

    final rawItems = order['items'] is List ? order['items'] as List : [];

    final items = rawItems.whereType<Map>().map((item) {
      final data = Map<String, dynamic>.from(item);
      final menu = data['menu'] is Map
          ? Map<String, dynamic>.from(data['menu'])
          : <String, dynamic>{};
      final quantity = _parseAmount(data['jumlah'] ?? data['quantity']);
      final subtotal = _parseAmount(data['subtotal']);
      final unitPrice = _parseAmount(
        data['harga_satuan'] ??
            data['harga'] ??
            data['price'] ??
            menu['harga'] ??
            menu['price'],
      );

      return {
        ...data,
        'name': data['nama_menu'] ?? menu['nama_menu'] ?? menu['name'] ?? '-',
        'quantity': quantity,
        'price': unitPrice > 0
            ? unitPrice
            : quantity > 0 && subtotal > 0
            ? (subtotal / quantity).round()
            : 0,
        'subtotal': subtotal > 0 ? subtotal : unitPrice * quantity,
      };
    }).toList();

    final status = formatStatus(order['status_pesanan']);
    final itemsTotal = items.fold<int>(
      0,
      (total, item) => total + _parseAmount(item['subtotal']),
    );
    final orderTotal = _parseAmount(order['total_harga'] ?? order['total']);

    return {
      ...order,
      'number': order['kode_pesanan'] ?? '-',
      'student': user['name'] ?? user['nama'] ?? 'Mahasiswa',
      'status': status,
      'total': orderTotal > 0 ? orderTotal : itemsTotal,
      'canteenNumber': order['nomor_kantin'] ?? 0,
      'canteen': order['nomor_kantin'] ?? 0,
      'servingType': order['metode_pengambilan'] == 'ambil_sendiri'
          ? 'takeaway'
          : 'dine_in',
      'items': items,
    };
  }

  // Mengambil pesanan dari database Laravel.
  Future<void> loadOrders() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await OrderApiService.instance.getPkOrders();

      if (!mounted) return;

      final convertedOrders = result
          .map((order) => convertOrder(order))
          .where(
            (order) =>
                int.tryParse(order['canteenNumber'].toString()) ==
                widget.canteenNumber,
          )
          .toList();

      setState(() {
        orders = convertedOrders;
        isLoading = false;
      });
      widget.onOrdersLoaded?.call(convertedOrders.length);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> openOrder(Map<String, dynamic> order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailOrderPage(order: order)),
    );

    if (!mounted) return;

    loadOrders();
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 65, color: purple),
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
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 55, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Gagal Memuat Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadOrders,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: widget.embedded
          ? null
          : AppBar(
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
              actions: [
                IconButton(
                  onPressed: loadOrders,
                  icon: const Icon(Icons.refresh, color: darkPurple),
                  tooltip: 'Muat ulang pesanan',
                ),
              ],
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : errorMessage != null
          ? buildErrorState()
          : RefreshIndicator(
              onRefresh: loadOrders,
              color: purple,
              child: orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: buildEmptyState(),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final items = (order['items'] as List<dynamic>?) ?? [];

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
                                  Text(
                                    order['student']?.toString() ?? 'Mahasiswa',
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    order['status']?.toString() ?? '-',
                                    style: const TextStyle(
                                      color: purple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${items.length} jenis menu',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
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
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: purple,
                            ),
                            onTap: () => openOrder(order),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
