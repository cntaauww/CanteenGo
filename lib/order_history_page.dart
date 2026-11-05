import 'package:flutter/material.dart';

import 'order_status_page.dart';
import 'services/order_api_service.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await OrderApiService.instance.getOrders();
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

  String statusLabel(dynamic value) {
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
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return value?.toString() ?? 'Status tidak diketahui';
    }
  }

  String canteenName(dynamic value) {
    switch (value?.toString()) {
      case '1':
        return 'Kantin Nasi';
      case '2':
        return 'Kantin Mi & Bakso';
      case '3':
        return 'Kantin Minuman';
      default:
        return 'Kantin ${value ?? '-'}';
    }
  }

  int parseAmount(dynamic value) {
    if (value is num) return value.round();

    final text = value?.toString().trim() ?? '';
    return double.tryParse(text)?.round() ??
        int.tryParse(text.replaceAll(RegExp(r'[^0-9-]'), '')) ??
        0;
  }

  String formatRupiah(dynamic value) {
    final amount = parseAmount(value);
    final digits = amount.toString();
    return 'Rp${digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  }

  String formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  Future<void> openOrder(Map<String, dynamic> order) async {
    final orderNumber = order['kode_pesanan']?.toString();
    if (orderNumber == null || orderNumber.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStatusPage(orderNumber: orderNumber),
      ),
    );

    if (mounted) loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkPurple),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadOrders,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : errorMessage != null
          ? _buildError()
          : orders.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              color: purple,
              onRefresh: loadOrders,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildOrderCard(orders[index]),
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: purple),
            const SizedBox(height: 12),
            const Text(
              'Riwayat belum bisa dimuat',
              style: TextStyle(
                color: darkPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loadOrders,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(backgroundColor: purple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 130),
        Icon(Icons.receipt_long_outlined, size: 64, color: purple),
        SizedBox(height: 14),
        Center(
          child: Text(
            'Belum ada riwayat pesanan',
            style: TextStyle(
              color: darkPurple,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            'Pesanan yang kamu buat akan muncul di sini.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final code = order['kode_pesanan']?.toString() ?? '-';
    final status = statusLabel(order['status_pesanan']);
    final items = order['items'] is List ? order['items'] as List : const [];
    final date = formatDate(order['created_at']);
    final canteen = canteenName(order['nomor_kantin']);

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF0EBFF),
          child: Icon(Icons.receipt_long_rounded, color: purple),
        ),
        title: Text(
          code,
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$canteen • ${items.length} menu'),
              if (date.isNotEmpty) Text(date),
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatRupiah(order['total_harga']),
                style: const TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: purple),
        onTap: () => openOrder(order),
      ),
    );
  }
}
