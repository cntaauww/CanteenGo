import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'pengelola_dashboard_page.dart';

class PengelolaLoginPage extends StatefulWidget {
  final String canteenId;

  const PengelolaLoginPage({super.key, required this.canteenId});

  @override
  State<PengelolaLoginPage> createState() => _PengelolaLoginPageState();
}

class _PengelolaLoginPageState extends State<PengelolaLoginPage> {
  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  int get canteenNumber {
    switch (widget.canteenId) {
      case 'nasi':
        return 1;
      case 'bakso':
        return 2;
      case 'minuman':
        return 3;
      default:
        return 0;
    }
  }

  String get canteenName {
    switch (widget.canteenId) {
      case 'nasi':
        return 'Kantin Nasi';
      case 'bakso':
        return 'Kantin Mi & Bakso';
      case 'minuman':
        return 'Kantin Minuman';
      default:
        return 'Kantin';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi.')),
      );
      return;
    }

    if (canteenNumber == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilihan kantin tidak valid.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.instance.login(
        email: email,
        password: password,
      );

      final data = result['data'];
      final user = data is Map ? data['user'] : null;

      if (user is! Map) {
        throw Exception('Data pengguna dari server tidak valid.');
      }

      final role = user['role']?.toString();
      final status = user['status_akun']?.toString();
      final rawCanteenNumber = user['nomor_kantin'];
      final tokenRole = role;

      final userCanteenNumber = int.tryParse(
        rawCanteenNumber?.toString() ?? '',
      );

      if (role != 'pk' ||
          status != 'aktif' ||
          userCanteenNumber != canteenNumber) {
        if (tokenRole != null) {
          await AuthService.instance.logout(role: tokenRole);
        }

        throw Exception(
          'Akun tidak memiliki akses ke $canteenName. '
          'Pastikan role, status akun, dan nomor kantin sesuai.',
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PengelolaDashboardPage(canteenId: widget.canteenId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Login $canteenName',
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: purple),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE6FA),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: purple,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Login Pengelola',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk mengelola $canteenName.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: purple,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    onSubmitted: (_) => login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: purple,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: purple,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : login,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        isLoading ? 'Memeriksa akun...' : 'Masuk',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
