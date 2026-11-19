import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _deviceBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.100.127:8000/api',
  );

  static const String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000/api'
      : _deviceBaseUrl;
}
