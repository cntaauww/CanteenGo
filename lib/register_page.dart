import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/api_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color lavender = Color(0xFF9B7DD4);
  static const Color darkPurple = Color(0xFF65469B);

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'nim': _nimController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      if (!mounted) return;

      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> result = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode == 201 && result['success'] == true) {
        Navigator.pop(context, true);
        return;
      }

      String message =
          result['message']?.toString() ??
          'Registrasi gagal. Silakan coba lagi.';

      final errors = result['errors'];

      if (errors is Map) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      }

      throw Exception(message);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
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

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7FF),
        foregroundColor: darkPurple,
        elevation: 0,
        title: const Text(
          'Buat Akun Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: lavender.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 42,
                          color: darkPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gabung CanteenGo! 💜',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat akun mahasiswa untuk mulai memesan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    _fieldLabel('Nama Lengkap'),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration(
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _fieldLabel('NIM'),
                    TextFormField(
                      controller: _nimController,
                      decoration: _decoration(
                        hint: 'Masukkan NIM mahasiswa',
                        icon: Icons.badge_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'NIM wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _fieldLabel('Email'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration(
                        hint: 'Masukkan email aktif',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi.';
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                          return 'Format email belum valid.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _fieldLabel('Password'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _decoration(
                        hint: 'Masukkan password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
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
                    ),
                    const SizedBox(height: 18),

                    _fieldLabel('Konfirmasi Password'),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: _decoration(
                        hint: 'Ulangi password',
                        icon: Icons.lock_reset_outlined,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password wajib diisi.';
                        }

                        if (value != _passwordController.text) {
                          return 'Konfirmasi password tidak cocok.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lavender,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: lavender.withValues(
                            alpha: 0.5,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                                'Buat Akun',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dengan mendaftar, akunmu akan dibuat '
                      'sebagai mahasiswa.',
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
