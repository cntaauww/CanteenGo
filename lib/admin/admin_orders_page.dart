import 'package:flutter/material.dart';

import '../services/order_api_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  static const Color purple = Color(0xFF9B7DD4);

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await OrderApiService.instance.getAdminOrders();
      if (!mounted) return;

      setState(() {
        orders = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (searchQuery.isEmpty) return orders;

    return orders.where((order) {
      final customer = order['user'];
      final customerName = customer is Map
          ? customer['name']?.toString() ?? ''
          : '';
      final searchableText = [
        order['kode_pesanan'],
        order['nomor_kantin'],
        order['status_pesanan'],
        order['status_pembayaran'],
        customerName,
      ].join(' ').toLowerCase();

      return searchableText.contains(searchQuery);
    }).toList();
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'menunggu_pembayaran':
        return 'Menunggu pembayaran';
      case 'menunggu_konfirmasi':
        return 'Menunggu konfirmasi';
      case 'diproses':
        return 'Diproses';
      case 'siap_diambil':
        return 'Siap diambil';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status?.replaceAll('_', ' ') ?? 'Status tidak diketahui';
    }
  }

  String _paymentLabel(String? status) {
    switch (status) {
      case 'belum_dikonfirmasi':
        return 'Belum dikonfirmasi';
      case 'menunggu_konfirmasi':
        return 'Menunggu konfirmasi';
      case 'terkonfirmasi':
        return 'Terkonfirmasi';
      default:
        return status?.replaceAll('_', ' ') ?? 'Tidak diketahui';
    }
  }

  String _formatRupiah(dynamic value) {
    final amount = value is num
        ? value.round()
        : num.tryParse(value?.toString() ?? '')?.round() ?? 0;
    final digits = amount.toString();
    final formatted = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      formatted.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) formatted.write('.');
    }

    return 'Rp$formatted';
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Waktu tidak tersedia';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        foregroundColor: const Color(0xFF7153A6),
        title: const Text(
          'Monitoring Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : fetchOrders,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari kode pesanan, nama, atau kantin...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEDE6F7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEDE6F7)),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.trim().toLowerCase());
              },
            ),
            const SizedBox(height: 18),
            Text(
              'Daftar Pesanan (${isLoading ? '...' : visibleOrders.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF332745),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              _messageState(
                icon: Icons.error_outline_rounded,
                message: errorMessage!,
                action: OutlinedButton.icon(
                  onPressed: fetchOrders,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              )
            else if (visibleOrders.isEmpty)
              _messageState(
                icon: Icons.receipt_long_outlined,
                message: orders.isEmpty
                    ? 'Belum ada pesanan.'
                    : 'Pesanan tidak ditemukan.',
              )
            else
              ...visibleOrders.map(_orderCard),
          ],
        ),
      ),
    );
  }

  Widget _messageState({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 18),
      child: Column(
        children: [
          Icon(icon, size: 44, color: purple),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final customer = order['user'];
    final customerName = customer is Map
        ? customer['name']?.toString() ?? 'Pengguna'
        : 'Pengguna';
    final items = order['items'] is List ? order['items'] as List : const [];
    final orderCode = order['kode_pesanan']?.toString() ?? '-';
    final orderStatus = order['status_pesanan']?.toString();
    final paymentStatus = order['status_pembayaran']?.toString();

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    orderCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Kantin ${order['nomor_kantin'] ?? '-'}',
                  style: const TextStyle(
                    color: Color(0xFF7153A6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$customerName • ${_formatDate(order['created_at'])}'),
            const Divider(height: 22),
            ...items.map((item) {
              if (item is! Map) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item['nama_menu']?.toString() ?? 'Menu'),
                    ),
                    Text('x${item['jumlah'] ?? 0}'),
                  ],
                ),
              );
            }),
            if (items.isEmpty)
              const Text(
                'Rincian menu tidak tersedia.',
                style: TextStyle(color: Colors.black54),
              ),
            const SizedBox(height: 10),
            Text('Pesanan: ${_statusLabel(orderStatus)}'),
            Text('Pembayaran: ${_paymentLabel(paymentStatus)}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatRupiah(order['total_harga']),
                style: const TextStyle(
                  color: Color(0xFF7153A6),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
