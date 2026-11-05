import 'package:flutter/material.dart';

import 'order_status_page.dart';
import 'services/student_order_notification_service.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  State<StudentNotificationsPage> createState() =>
      _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  final StudentOrderNotificationService _notificationService =
      StudentOrderNotificationService.instance;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _notificationService.markAllRead();
    _notificationService.start();
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      await _notificationService.refresh();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'menunggu_pembayaran':
        return 'Menunggu pembayaran';
      case 'menunggu_konfirmasi':
        return 'Menunggu konfirmasi';
      case 'diproses':
        return 'Pesanan sedang diproses';
      case 'siap_diambil':
        return 'Pesanan siap diambil';
      case 'selesai':
        return 'Pesanan selesai';
      case 'dibatalkan':
        return 'Pesanan dibatalkan';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'siap_diambil':
        return Icons.check_circle_rounded;
      case 'selesai':
        return Icons.task_alt_rounded;
      case 'dibatalkan':
        return Icons.cancel_rounded;
      case 'diproses':
        return Icons.soup_kitchen_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String _canteenName(dynamic value) {
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

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

  Future<void> _openOrder(String orderCode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStatusPage(orderNumber: orderCode),
      ),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Notifikasi Pesanan',
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkPurple),
        actions: [
          IconButton(
            onPressed: _isRefreshing ? null : _refresh,
            tooltip: 'Perbarui status pesanan',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: purple,
        onRefresh: _refresh,
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _notificationService.orders,
          builder: (context, orders, _) {
            if (_errorMessage != null && orders.isEmpty) {
              return _emptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Notifikasi belum bisa dimuat',
                subtitle: _errorMessage!,
                action: TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              );
            }

            if (orders.isEmpty && !_notificationService.hasLoadedOrders) {
              return const Center(
                child: CircularProgressIndicator(color: purple),
              );
            }

            if (orders.isEmpty) {
              return _emptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Belum ada notifikasi pesanan',
                subtitle: 'Pembaruan status akan muncul di sini setelah kamu membuat pesanan.',
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Status terbaru pesananmu',
                    style: TextStyle(
                      color: darkPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...orders.map(_orderNotificationCard),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 130),
        Icon(icon, size: 60, color: purple),
        const SizedBox(height: 14),
        Center(
          child: Text(
            title,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        if (action != null) ...[
          const SizedBox(height: 12),
          Center(child: action),
        ],
      ],
    );
  }

  Widget _orderNotificationCard(Map<String, dynamic> order) {
    final code = order['kode_pesanan']?.toString() ?? '-';
    final status = order['status_pesanan']?.toString() ?? '';
    final updatedAt = _formatDate(order['updated_at']);
    final itemCount = order['items'] is List
        ? (order['items'] as List).length
        : 0;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDE6F7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF0EBFF),
          child: Icon(_statusIcon(status), color: purple),
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
              Text(_canteenName(order['nomor_kantin'])),
              const SizedBox(height: 4),
              Text(
                _statusLabel(status),
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (updatedAt.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text('Diperbarui $updatedAt'),
              ],
              Text('$itemCount menu'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: purple),
        onTap: code == '-' ? null : () => _openOrder(code),
      ),
    );
  }
}
