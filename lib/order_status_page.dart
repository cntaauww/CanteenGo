import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/auth_service.dart';

class OrderStatusPage extends StatefulWidget {
  final String orderNumber;

  const OrderStatusPage({super.key, required this.orderNumber});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  static const Color purple = Color(0xFF8061C9);
  static const Color darkPurple = Color(0xFF40305F);
  static const Color background = Color(0xFFFAF8FF);

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _order;

  final List<String> _statusSteps = [
    'Menunggu Pembayaran',
    'Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await AuthService.instance.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Silakan login kembali untuk melihat pesanan.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await AuthService.instance.clearToken();
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons pesanan dari server tidak valid.');
      }

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Gagal mengambil data pesanan.',
        );
      }

      final data = decoded['data'];

      if (data is! List) {
        throw Exception('Daftar pesanan dari server tidak valid.');
      }

      Map<String, dynamic>? foundOrder;

      for (final item in data) {
        if (item is! Map) continue;

        final order = Map<String, dynamic>.from(item);
        final serverCode = order['kode_pesanan']?.toString().trim();

        if (serverCode == widget.orderNumber.trim()) {
          foundOrder = order;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _order = foundOrder;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _statusLabel(dynamic rawStatus) {
    switch (rawStatus?.toString()) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'diproses':
        return 'Diproses';
      case 'siap_diambil':
        return 'Siap Diambil';
      case 'selesai':
        return 'Selesai';
      default:
        return rawStatus?.toString() ?? 'Belum diketahui';
    }
  }

  int _statusIndex(String status) {
    final index = _statusSteps.indexOf(status);
    return index < 0 ? 0 : index;
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return 'Bayar langsung kepada penjual dan tunjukkan bukti pembayaran. Pengelola kantin akan memeriksa dan memperbarui status pesananmu.';
      case 'Menunggu Konfirmasi':
        return 'Pengelola kantin sedang memeriksa bukti pembayaranmu.';
      case 'Diproses':
        return 'Pesananmu sedang disiapkan oleh pengelola kantin.';
      case 'Siap Diambil':
        return 'Pesananmu siap diambil di kantin.';
      case 'Selesai':
        return 'Pesananmu telah selesai. Terima kasih telah menggunakan CanteenGo!';
      default:
        return 'Informasi status pesanan belum tersedia.';
    }
  }

  String _canteenName(dynamic number) {
    switch (number?.toString()) {
      case '1':
        return 'Kantin Nasi';
      case '2':
        return 'Kantin Mi & Bakso';
      case '3':
        return 'Kantin Minuman';
      default:
        return 'Kantin';
    }
  }

  String _servingType(dynamic value) {
    switch (value?.toString()) {
      case 'ambil_sendiri':
        return 'Ambil Sendiri';
      case 'makan_di_tempat':
        return 'Makan di Tempat';
      default:
        return value?.toString() ?? '-';
    }
  }

  int _asInt(dynamic value) {
    if (value is num) return value.round();

    return int.tryParse(value?.toString() ?? '') ??
        double.tryParse(value?.toString() ?? '')?.round() ??
        0;
  }

  String _rupiah(dynamic value) {
    final amount = _asInt(value);
    final digits = amount.toString();

    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Status Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: purple,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: purple));
    }

    if (_errorMessage != null) {
      return _messageState(
        icon: Icons.cloud_off_outlined,
        title: 'Gagal memuat pesanan',
        message: _errorMessage!,
        buttonText: 'Coba Lagi',
        onPressed: _loadOrder,
      );
    }

    final currentOrder = _order;

    if (currentOrder == null) {
      return _messageState(
        icon: Icons.receipt_long_outlined,
        title: 'Pesanan tidak ditemukan',
        message:
            'Kode pesanan ${widget.orderNumber} tidak ditemukan '
            'dalam riwayat akun ini. Pastikan kamu login dengan '
            'akun yang digunakan saat membuat pesanan.',
        buttonText: 'Periksa Kembali',
        onPressed: _loadOrder,
      );
    }

    final status = _statusLabel(currentOrder['status_pesanan']);
    final activeIndex = _statusIndex(status);
    final total = currentOrder['total_harga'];

    final items = currentOrder['items'] is List
        ? currentOrder['items'] as List
        : <dynamic>[];

    return RefreshIndicator(
      color: purple,
      onRefresh: _loadOrder,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE5FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: purple,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Pesanan Berhasil Dibuat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Nomor pesanan kamu:'),
                const SizedBox(height: 5),
                SelectableText(
                  currentOrder['kode_pesanan']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: purple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9DFFF), Color(0xFFFFEAF3)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS SAAT INI',
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_statusDescription(status)),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'Perjalanan Pesanan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 18),

          ...List.generate(_statusSteps.length, (index) {
            final isDone = index <= activeIndex;
            final isCurrent = index == activeIndex;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: isDone ? purple : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : Icons.circle_outlined,
                          size: 18,
                          color: isDone ? Colors.white : Colors.grey,
                        ),
                      ),
                      if (index < _statusSteps.length - 1)
                        Container(
                          height: 40,
                          width: 2,
                          color: index < activeIndex
                              ? purple
                              : Colors.grey.shade300,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 25),
                    child: Text(
                      _statusSteps[index],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isDone ? darkPurple : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 4),

          const Text(
            'Rincian Pesanan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 12),

          _detailRow('Kantin', _canteenName(currentOrder['nomor_kantin'])),
          _detailRow(
            'Jenis Pesanan',
            _servingType(currentOrder['metode_pengambilan']),
          ),
          _detailRow('Total', _rupiah(total)),

          const SizedBox(height: 18),

          const Text(
            'Menu yang dipesan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (items.isEmpty)
            const Text('Rincian menu tidak tersedia.')
          else
            ...items.map((item) {
              if (item is! Map) {
                return const SizedBox.shrink();
              }

              final menu = Map<String, dynamic>.from(item);
              final name = menu['nama_menu']?.toString() ?? 'Menu';
              final quantity = _asInt(menu['jumlah']);
              final subtotal = menu['subtotal'];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFEDE6F7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_rounded, color: purple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('Jumlah: $quantity'),
                        ],
                      ),
                    ),
                    Text(
                      _rupiah(subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                  ],
                ),
              );
            }),

          if ((currentOrder['catatan']?.toString().trim() ?? '')
              .isNotEmpty) ...[
            const SizedBox(height: 12),
            _detailRow('Catatan', currentOrder['catatan'].toString()),
          ],

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _loadOrder,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Perbarui Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: purple,
                side: const BorderSide(color: purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 62, color: purple),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const Text(': '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
