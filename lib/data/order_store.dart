class OrderStore {
  OrderStore._();

  static final List<Map<String, dynamic>> orders = [];

  static int _lastOrderNumber = 0;

  static Map<String, dynamic> addOrder({
    required int canteenNumber,
    required List<Map<String, dynamic>> items,
    required int total,
  }) {
    _lastOrderNumber++;

    final orderNumber = 'CG${_lastOrderNumber.toString().padLeft(3, '0')}';

    final order = <String, dynamic>{
      'number': orderNumber,
      'canteen': 'Kantin $canteenNumber',
      'canteenNumber': canteenNumber,
      'items': items,
      'total': total,
      'status': 'Menunggu Pembayaran',
    };

    orders.insert(0, order);

    return order;
  }
}
