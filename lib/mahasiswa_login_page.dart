import 'package:flutter/material.dart';

import 'checkout_page.dart';
import 'services/auth_service.dart';
import 'register_page.dart';

class MahasiswaLoginPage extends StatefulWidget {
  final Map<String, int>? cart;
  final List<Map<String, dynamic>>? menus;
  final int? canteenNumber;
  final Map<String, String>? notes;

  const MahasiswaLoginPage({
    super.key,
    this.cart,
    this.menus,
    this.canteenNumber,
    this.notes,
  });

  @override
  State<MahasiswaLoginPage> createState() => _MahasiswaLoginPageState();
}

class _MahasiswaLoginPageState extends State<MahasiswaLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color lavender = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF65469B);
  static const Color background = Color(0xFFF9F7FF);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final data = result['data'];
      final user = data is Map ? data['user'] : null;

      if (user is! Map) {
        throw Exception('Data pengguna dari server tidak valid.');
      }

      final role = user['role']?.toString();
      final status = user['status_akun']?.toString();

      if (role != 'mahasiswa') {
        if (role != null) {
          await AuthService.instance.logout(role: role);
        }

        if (!mounted) return;

        throw Exception(
          'Akun ini bukan akun mahasiswa. '
          'Silakan gunakan akun mahasiswa.',
        );
      }

      if (status != 'aktif') {
        await AuthService.instance.logout(role: 'mahasiswa');

        if (!mounted) return;

        throw Exception('Akun kamu belum aktif.');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: darkPurple,
        ),
      );

      final hasCheckoutData =
          widget.cart != null &&
          widget.menus != null &&
          widget.canteenNumber != null &&
          widget.notes != null;

      if (hasCheckoutData) {
        // Login berasal dari Checkout.
        // Pertahankan keranjang dan kembali ke Checkout.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutPage(
              cart: widget.cart!,
              menus: widget.menus!,
              canteenNumber: widget.canteenNumber!,
              notes: widget.notes!,
            ),
          ),
        );
      } else {
        // Login berasal dari Profil.
        // Kembali ke Profil.
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegisterPage() async {
    if (_isLoading) return;

    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );

    if (!mounted) return;

    if (registered == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan login.'),
          backgroundColor: darkPurple,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: lavender.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: lavender, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkPurple,
        elevation: 0,
        title: const Text(
          'Login Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: lavender.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 44,
                          color: darkPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Halo, Mahasiswa! 💜',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Login terlebih dahulu untuk '
                      'melanjutkan pesananmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: _inputDecoration(
                        hint: 'Masukkan email mahasiswa',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi.';
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                          return 'Masukkan email yang valid.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: _inputDecoration(
                        hint: 'Masukkan password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lavender,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: lavender.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Login dan Lanjutkan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Tombol menuju halaman pendaftaran.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Belum punya akun?',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _openRegisterPage,
                          child: const Text(
                            'Buat Akun',
                            style: TextStyle(
                              color: darkPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Pastikan akun mahasiswa sudah '
                      'terdaftar dan aktif.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
