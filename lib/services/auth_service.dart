import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _tokenKey = 'canteengo_token';
  static const String _userKey = 'canteengo_user';

  // Mengambil token login yang tersimpan.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Mengambil data pengguna yang tersimpan.
  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(userJson);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // Menyimpan token login.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Menghapus token dan data pengguna lokal.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Login mahasiswa, pengelola kantin, atau admin.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons login dari server tidak valid.');
      }

      final result = decoded;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = result['data'];

        if (data is! Map<String, dynamic>) {
          throw Exception('Data login tidak ditemukan.');
        }

        final dynamic tokenValue = data['token'];
        final dynamic userValue = data['user'];

        if (tokenValue is! String || tokenValue.isEmpty) {
          throw Exception('Login berhasil, tetapi token tidak ditemukan.');
        }

        if (userValue is! Map<String, dynamic>) {
          throw Exception(
            'Login berhasil, tetapi data pengguna tidak ditemukan.',
          );
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(_tokenKey, tokenValue);
        await prefs.setString(_userKey, jsonEncode(userValue));

        return result;
      }

      throw Exception(
        result['message']?.toString() ??
            'Login gagal. Periksa email dan password.',
      );
    } on FormatException {
      throw Exception('Respons server tidak dapat dibaca.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Tidak dapat terhubung ke server Laravel. '
        'Pastikan server sedang berjalan.',
      );
    }
  }

  // Mengambil profil pengguna dari Laravel.
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Kamu belum login.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons profil dari server tidak valid.');
      }

      final result = decoded;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = result['data'];

        if (data is! Map<String, dynamic>) {
          throw Exception('Data profil pengguna tidak ditemukan.');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(data));

        return data;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await clearToken();
      }

      throw Exception(
        result['message']?.toString() ?? 'Gagal mengambil profil pengguna.',
      );
    } on FormatException {
      throw Exception('Respons profil dari server tidak dapat dibaca.');
    }
  }

  // Logout dari Laravel dan hapus data login lokal.
  Future<void> logout() async {
    final token = await getToken();

    try {
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } finally {
      await clearToken();
    }
  }
}
