import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _tokenKey = 'canteengo_token';
  static const String _userKey = 'canteengo_user';

  String _tokenKeyForRole(String role) => '${_tokenKey}_$role';

  String _userKeyForRole(String role) => '${_userKey}_$role';

  Map<String, dynamic>? _decodeUser(String? userJson) {
    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(userJson);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  // Mengambil token login sesuai peran agar sesi mahasiswa dan PK terpisah.
  Future<String?> getToken({required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    final roleToken = prefs.getString(_tokenKeyForRole(role));

    if (roleToken != null && roleToken.isNotEmpty) {
      return roleToken;
    }

    final legacyUser = _decodeUser(prefs.getString(_userKey));
    if (legacyUser?['role'] != role) {
      return null;
    }

    final legacyToken = prefs.getString(_tokenKey);
    if (legacyToken == null || legacyToken.isEmpty) {
      return null;
    }

    await prefs.setString(_tokenKeyForRole(role), legacyToken);
    await prefs.setString(_userKeyForRole(role), jsonEncode(legacyUser));

    return legacyToken;
  }

  // Mengambil data pengguna yang tersimpan sesuai peran.
  Future<Map<String, dynamic>?> getSavedUser({required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    final roleUserJson = prefs.getString(_userKeyForRole(role));
    if (roleUserJson != null) {
      return _decodeUser(roleUserJson);
    }

    final legacyUserJson = prefs.getString(_userKey);
    final legacyUser = _decodeUser(legacyUserJson);
    if (legacyUser?['role'] != role) {
      return null;
    }

    await prefs.setString(_userKeyForRole(role), legacyUserJson!);
    return legacyUser;
  }

  // Menyimpan token login.
  Future<void> saveToken(String token, {required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKeyForRole(role), token);
  }

  // Menghapus token dan data pengguna lokal untuk satu peran.
  Future<void> clearToken({required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKeyForRole(role));
    await prefs.remove(_userKeyForRole(role));

    final legacyUser = _decodeUser(prefs.getString(_userKey));
    if (legacyUser?['role'] == role) {
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
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

        final role = userValue['role']?.toString();
        if (role == null || !{'mahasiswa', 'pk', 'admin'}.contains(role)) {
          throw Exception('Peran pengguna dari server tidak valid.');
        }

        final prefs = await SharedPreferences.getInstance();

        await saveToken(tokenValue, role: role);
        await prefs.setString(_userKeyForRole(role), jsonEncode(userValue));

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
  Future<Map<String, dynamic>> getProfile({required String role}) async {
    final token = await getToken(role: role);

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
        await prefs.setString(_userKeyForRole(role), jsonEncode(data));

        return data;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await clearToken(role: role);
      }

      throw Exception(
        result['message']?.toString() ?? 'Gagal mengambil profil pengguna.',
      );
    } on FormatException {
      throw Exception('Respons profil dari server tidak dapat dibaca.');
    }
  }

  // Logout dari Laravel dan hapus data login lokal.
  Future<void> logout({required String role}) async {
    final token = await getToken(role: role);

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
      await clearToken(role: role);
    }
  }
}
