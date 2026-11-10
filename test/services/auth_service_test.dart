import 'package:canteen_go/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('keeps student and PK login tokens separate', () async {
    final authService = AuthService.instance;

    await authService.saveToken('student-token', role: 'mahasiswa');
    await authService.saveToken('pk-token', role: 'pk');

    expect(await authService.getToken(role: 'mahasiswa'), 'student-token');
    expect(await authService.getToken(role: 'pk'), 'pk-token');
  });

  test('clearing one role token does not clear another role session', () async {
    final authService = AuthService.instance;

    await authService.saveToken('student-token', role: 'mahasiswa');
    await authService.saveToken('pk-token', role: 'pk');

    await authService.clearToken(role: 'pk');

    expect(await authService.getToken(role: 'pk'), isNull);
    expect(await authService.getToken(role: 'mahasiswa'), 'student-token');
  });

  test('migrates a legacy token only for its saved user role', () async {
    SharedPreferences.setMockInitialValues({
      'canteengo_token': 'legacy-pk-token',
      'canteengo_user': '{"role":"pk"}',
    });
    final authService = AuthService.instance;

    expect(await authService.getToken(role: 'pk'), 'legacy-pk-token');
    expect(await authService.getToken(role: 'mahasiswa'), isNull);
  });
}
