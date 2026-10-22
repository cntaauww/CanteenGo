import 'dart:convert';

import 'package:http/http.dart' as http;

class MenuApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Map<String, dynamic>>> getMenus({
    required int canteenNumber,
  }) async {
    final uri = Uri.parse('$baseUrl/menus')
        .replace(queryParameters: {'nomor_kantin': canteenNumber.toString()});

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil menu. Kode: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> ||
        decoded['success'] != true ||
        decoded['data'] is! List) {
      throw Exception('Respons daftar menu tidak valid.');
    }

    return (decoded['data'] as List)
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();
  }

  Future<Map<String, dynamic>> createMenu({
    required int canteenNumber,
    required Map<String, dynamic> menu,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/menus'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(_toApiPayload(menu, canteenNumber)),
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateMenu({
    required int id,
    required int canteenNumber,
    required Map<String, dynamic> menu,
  }) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/menus/$id'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(_toApiPayload(menu, canteenNumber)),
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<void> deleteMenu(int id) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/menus/$id'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    _handleResponse(response);
  }

  Map<String, dynamic> _toApiPayload(
    Map<String, dynamic> menu,
    int canteenNumber,
  ) {
    final rawPrice = menu['price'] ?? menu['harga'] ?? 0;
    final rawStock = menu['stock'] ?? menu['stok'] ?? 0;

    return {
      'nomor_kantin': canteenNumber,
      'nama_menu': (menu['name'] ?? menu['nama_menu'] ?? '').toString(),
      'deskripsi': menu['deskripsi']?.toString(),
      'harga': rawPrice is num
          ? rawPrice
          : double.tryParse(rawPrice.toString()) ?? 0,
      'stok': rawStock is num
          ? rawStock.toInt()
          : int.tryParse(rawStock.toString()) ?? 0,
      'tersedia': menu['available'] ?? menu['tersedia'] ?? true,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Respons Laravel tidak valid. Kode: ${response.statusCode}',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded is! Map<String, dynamic> ||
        decoded['success'] != true) {
      final message = decoded is Map ? decoded['message']?.toString() : null;

      throw Exception(
        message ?? 'Permintaan gagal. Kode: ${response.statusCode}',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }
}
