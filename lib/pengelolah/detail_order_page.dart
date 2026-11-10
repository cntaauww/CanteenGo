import 'package:flutter/material.dart';

import '../services/order_api_service.dart';

class DetailOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const DetailOrderPage({super.key, required this.order});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  late String status;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    status = widget.order['status']?.toString() ?? 'Menunggu Pembayaran';
  }

  Future<void> confirmPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: const Text(
          'Pastikan bukti pembayaran sudah ditunjukkan dan diperiksa '
          'langsung. Lanjutkan konfirmasi pembayaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, sudah diperiksa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final orderId = int.tryParse(widget.order['id']?.toString() ?? '');

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pesanan tidak ditemukan.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await OrderApiService.instance.confirmPayment(orderId: orderId);

      if (!mounted) return;

      setState(() {
        status = 'Diproses';
        widget.order['status'] = 'Diproses';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil dikonfirmasi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> markReady() async {
    final orderId = int.tryParse(widget.order['id']?.toString() ?? '');

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pesanan tidak ditemukan.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await OrderApiService.instance.markOrderReady(orderId: orderId);

      if (!mounted) return;

      setState(() {
        status = 'Siap Diambil';
        widget.order['status'] = 'Siap Diambil';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan ditandai siap diambil.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> markComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Selesaikan Pesanan'),
        content: const Text(
          'Pastikan pesanan sudah diambil oleh mahasiswa. Tandai pesanan selesai?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Selesaikan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final orderId = int.tryParse(widget.order['id']?.toString() ?? '');

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pesanan tidak ditemukan.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await OrderApiService.instance.markOrderComplete(orderId: orderId);

      if (!mounted) return;

      setState(() {
        status = 'Selesai';
        widget.order['status'] = 'Selesai';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil diselesaikan.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final items = (order['items'] as List<dynamic>?) ?? [];

    final int total = int.tryParse(order['total']?.toString() ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Detail Pesanan Mahasiswa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order['number']?.toString() ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Informasi Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoRow('Nomor Pesanan', order['number']?.toString() ?? '-'),
            _infoRow('Kantin', order['canteen']?.toString() ?? '-'),
            _infoRow('Jenis Pesanan', order['servingType']?.toString() ?? '-'),
            _infoRow('Total Pembayaran', 'Rp ${total.toString()}'),

            const SizedBox(height: 24),

            const Text(
              'Menu yang Dipesan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (items.isEmpty)
              const Text('Tidak ada detail menu.')
            else
              ...items.map((item) {
                final menu = Map<String, dynamic>.from(item as Map);

                final String nama =
                    menu['name']?.toString() ??
                    menu['nama']?.toString() ??
                    'Menu';

                final int jumlah =
                    int.tryParse(
                      menu['quantity']?.toString() ??
                          menu['jumlah']?.toString() ??
                          '1',
                    ) ??
                    1;

                final int harga =
                    int.tryParse(
                      menu['price']?.toString() ??
                          menu['harga']?.toString() ??
                          '0',
                    ) ??
                    0;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.restaurant,
                      color: Colors.deepPurple,
                    ),
                    title: Text(nama),
                    subtitle: Text('Jumlah: $jumlah'),
                    trailing: Text('Rp ${(harga * jumlah).toString()}'),
                  ),
                );
              }),

            const SizedBox(height: 24),

            const Text(
              'Status Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (status == 'Menunggu Pembayaran' ||
                status == 'Menunggu Konfirmasi')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : confirmPayment,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    isLoading ? 'Memproses...' : 'Konfirmasi Pembayaran',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              )
            else if (status == 'Diproses')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : markReady,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    isLoading ? 'Memproses...' : 'Tandai Siap Diambil',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              )
            else if (status == 'Siap Diambil')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : markComplete,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.task_alt),
                  label: Text(
                    isLoading ? 'Memproses...' : 'Selesaikan Pesanan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status == 'Siap Diambil'
                      ? 'Pesanan sudah siap diambil mahasiswa.'
                      : status == 'Selesai'
                      ? 'Pesanan telah selesai.'
                      : 'Status pesanan: $status.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
