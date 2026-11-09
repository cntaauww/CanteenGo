import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class OrderApiService {
  OrderApiService._();

  static final OrderApiService instance = OrderApiService._();

  // Membuat pesanan baru melalui Laravel.
  Future<Map<String, dynamic>> createOrder({
    required int canteenNumber,
    required String servingType,
    required List<Map<String, int>> items,
    String? notes,
  }) async {
    final token = await AuthService.instance.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Silakan login terlebih dahulu untuk membuat pesanan.');
    }

    if (items.isEmpty) {
      throw Exception('Keranjang pesanan masih kosong.');
    }

    final apiItems = items.map((item) {
      final menuId = item['menu_id'];
      final quantity = item['jumlah'];

      if (menuId == null || menuId <= 0) {
        throw Exception(
          'ID menu dari database tidak ditemukan. Muat ulang daftar menu.',
        );
      }

      if (quantity == null || quantity <= 0) {
        throw Exception('Jumlah pesanan tidak valid.');
      }

      return {'menu_id': menuId, 'jumlah': quantity};
    }).toList();

    final metodePengambilan = servingType == 'takeaway'
        ? 'ambil_sendiri'
        : 'makan_di_tempat';

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nomor_kantin': canteenNumber,
          'metode_pengambilan': metodePengambilan,
          'catatan': notes == null || notes.trim().isEmpty
              ? null
              : notes.trim(),
          'items': apiItems,
        }),
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons server pesanan tidak valid.');
      }

      if (response.statusCode == 201 && decoded['success'] == true) {
        final dynamic data = decoded['data'];

        if (data is! Map<String, dynamic> || data['kode_pesanan'] == null) {
          throw Exception('Kode pesanan dari server tidak ditemukan.');
        }

        return data;
      }

      if (response.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }

      if (response.statusCode == 403) {
        throw Exception(
          decoded['message']?.toString() ??
              'Akun tidak memiliki izin membuat pesanan.',
        );
      }

      if (response.statusCode == 422) {
        final errors = decoded['errors'];

        if (errors is Map<String, dynamic>) {
          final messages = <String>[];

          for (final value in errors.values) {
            if (value is List) {
              messages.addAll(value.map((e) => e.toString()));
            }
          }

          if (messages.isNotEmpty) {
            throw Exception(messages.join('\n'));
          }
        }
      }

      throw Exception(
        decoded['message']?.toString() ??
            'Pesanan gagal dibuat. Silakan coba kembali.',
      );
    } on FormatException {
      throw Exception('Respons server tidak dapat dibaca.');
    }
  }

  // Mengambil riwayat pesanan mahasiswa.
  Future<List<Map<String, dynamic>>> getOrders() async {
    return _getOrdersFromEndpoint('/orders');
  }

  // Mengambil pesanan masuk khusus PK.
  Future<List<Map<String, dynamic>>> getPkOrders() async {
    return _getOrdersFromEndpoint('/pk/orders');
  }

  // Mengambil pesanan dari seluruh kantin khusus admin.
  Future<List<Map<String, dynamic>>> getAdminOrders() async {
    return _getOrdersFromEndpoint('/admin/orders');
  }

  // Fungsi umum untuk mengambil daftar pesanan dari Laravel.
  Future<List<Map<String, dynamic>>> _getOrdersFromEndpoint(
    String endpoint,
  ) async {
    final token = await AuthService.instance.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Silakan login untuk melihat pesanan.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons daftar pesanan tidak valid.');
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        final dynamic data = decoded['data'];

        if (data is! List) {
          throw Exception('Format daftar pesanan dari server tidak valid.');
        }

        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (response.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }

      throw Exception(
        decoded['message']?.toString() ?? 'Daftar pesanan gagal dimuat.',
      );
    } on FormatException {
      throw Exception('Respons server tidak dapat dibaca.');
    }
  }

  // Mengonfirmasi pembayaran pesanan oleh pengelola kantin.
  Future<void> confirmPayment({required int orderId}) async {
    final token = await AuthService.instance.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Silakan login kembali.');
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/confirm-payment'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons server tidak valid.');
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        return;
      }

      if (response.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }

      throw Exception(
        decoded['message']?.toString() ?? 'Konfirmasi pembayaran gagal.',
      );
    } on FormatException {
      throw Exception('Respons server tidak dapat dibaca.');
    }
  }

  // Menandai pesanan yang sudah dibayar sebagai siap diambil oleh PK.
  Future<void> markOrderReady({required int orderId}) async {
    final token = await AuthService.instance.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Silakan login kembali.');
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/mark-ready'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons server tidak valid.');
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        return;
      }

      if (response.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }

      throw Exception(
        decoded['message']?.toString() ?? 'Status pesanan gagal diperbarui.',
      );
    } on FormatException {
      throw Exception('Respons server tidak dapat dibaca.');
    }
  }
}
