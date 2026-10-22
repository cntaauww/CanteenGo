import 'package:flutter/foundation.dart';

class OrderStore {
  OrderStore._();

  // Keranjang aktif mahasiswa, dipisahkan berdasarkan kantin.
  static final Map<int, Map<String, int>> _carts = {};

  // Semua pesanan yang sudah berhasil dibuat.
  static final List<Map<String, dynamic>> orders = [];

  static int _lastOrderNumber = 0;

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void notifyChanged() {
    revision.value++;
  }

  static Map<String, int> cartFor(int canteenNumber) {
    return _carts.putIfAbsent(canteenNumber, () => {});
  }

  static Map<String, dynamic>? getOrderByNumber(String orderNumber) {
    for (final order in orders) {
      if (order['number']?.toString() == orderNumber) {
        return order;
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> ordersForCanteen(int canteenNumber) {
    return orders.where((order) {
      return order['canteenNumber'] == canteenNumber;
    }).toList();
  }

  static List<Map<String, dynamic>> get studentOrders {
    return List<Map<String, dynamic>>.unmodifiable(orders);
  }

  static Map<String, dynamic>? latestOrderForCanteen(int canteenNumber) {
    for (final order in orders) {
      if (order['canteenNumber'] == canteenNumber) {
        return order;
      }
    }
    return null;
  }

  static Map<String, dynamic> addOrder({
    required int canteenNumber,
    required List<Map<String, dynamic>> items,
    required int total,
    required String servingType,
  }) {
    _lastOrderNumber++;

    final orderNumber = 'CG${_lastOrderNumber.toString().padLeft(3, '0')}';

    final order = <String, dynamic>{
      'number': orderNumber,
      'canteen': 'Kantin $canteenNumber',
      'canteenNumber': canteenNumber,
      'items': items.map((item) => Map<String, dynamic>.from(item)).toList(),
      'total': total,
      'servingType': servingType,
      'status': 'Menunggu Pembayaran',
    };

    orders.insert(0, order);

    // Keranjang hanya dikosongkan setelah pesanan berhasil dibuat.
    cartFor(canteenNumber).clear();

    notifyChanged();
    return order;
  }

  static bool updateStatus({
    required String orderNumber,
    required String status,
  }) {
    final order = getOrderByNumber(orderNumber);

    if (order == null) {
      return false;
    }

    order['status'] = status;
    notifyChanged();
    return true;
  }
}
