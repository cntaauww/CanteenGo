import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'order_api_service.dart';

class StudentOrderStatusNotification {
  const StudentOrderStatusNotification({
    required this.orderCode,
    required this.canteenNumber,
    required this.previousStatus,
    required this.currentStatus,
    required this.updatedAt,
  });

  final String orderCode;
  final String canteenNumber;
  final String previousStatus;
  final String currentStatus;
  final String updatedAt;
}

class StudentOrderNotificationService {
  StudentOrderNotificationService._();

  static final StudentOrderNotificationService instance =
      StudentOrderNotificationService._();

  static const Duration _pollInterval = Duration(seconds: 30);
  static const int _maxNotifications = 50;

  final ValueNotifier<List<Map<String, dynamic>>> orders = ValueNotifier(
    const [],
  );
  final ValueNotifier<List<StudentOrderStatusNotification>> notifications =
      ValueNotifier(const []);
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  Timer? _timer;
  bool _isRefreshing = false;
  bool _hasBaseline = false;
  Map<String, String> _knownStatuses = {};

  bool get hasLoadedOrders => _hasBaseline;

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(_pollInterval, (_) {
      refresh().catchError((Object error) {
        debugPrint('Gagal memperbarui notifikasi pesanan: $error');
      });
    });

    refresh().catchError((Object error) {
      debugPrint('Gagal memuat notifikasi pesanan: $error');
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final token = await AuthService.instance.getToken(role: 'mahasiswa');
      if (token == null || token.isEmpty) {
        _hasBaseline = true;
        orders.value = const [];
        return;
      }

      final result = await OrderApiService.instance.getOrders();
      final currentStatuses = <String, String>{};

      for (final order in result) {
        final code = order['kode_pesanan']?.toString();
        final status = order['status_pesanan']?.toString();
        if (code == null || code.isEmpty || status == null) continue;

        currentStatuses[code] = status;
        final previousStatus = _knownStatuses[code];
        if (_hasBaseline &&
            previousStatus != null &&
            previousStatus != status) {
          _addNotification(
            StudentOrderStatusNotification(
              orderCode: code,
              canteenNumber: order['nomor_kantin']?.toString() ?? '-',
              previousStatus: previousStatus,
              currentStatus: status,
              updatedAt: order['updated_at']?.toString() ?? '',
            ),
          );
        }
      }

      _knownStatuses = currentStatuses;
      _hasBaseline = true;
      orders.value = result;
    } finally {
      _isRefreshing = false;
    }
  }

  void markAllRead() {
    unreadCount.value = 0;
  }

  void _addNotification(StudentOrderStatusNotification notification) {
    notifications.value = [
      notification,
      ...notifications.value,
    ].take(_maxNotifications).toList();
    unreadCount.value++;
  }
}
