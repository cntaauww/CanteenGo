import 'package:flutter/foundation.dart';

import '../services/menu_api_service.dart';

class MenuStore extends ChangeNotifier {
  MenuStore._();

  static final MenuStore instance = MenuStore._();

  final MenuApiService _menuApiService = MenuApiService();

  final Map<String, int> _canteenNumbers = {
    'nasi': 1,
    'bakso': 2,
    'minuman': 3,
  };

  final Set<String> _loadingCanteens = {};
  final Set<String> _loadedCanteens = {};

  final Map<String, List<Map<String, dynamic>>> _menus = {
    'nasi': [
      {
        'name': 'Nasi Goreng',
        'price': 13000,
        'stock': 10,
        'available': true,
        'icon': '🍳',
        'image': 'assets/images/nasi goreng.jpg',
      },
      {
        'name': 'Nasi Ayam Geprek',
        'price': 15000,
        'stock': 10,
        'available': true,
        'icon': '🍗',
        'image': 'assets/images/ayam geprek.jpg',
      },
      {
        'name': 'Nasi Kuning',
        'price': 12000,
        'stock': 8,
        'available': true,
        'icon': '🍚',
        'image': 'assets/images/Nasi kuning.jpg',
      },
      {
        'name': 'Nasi Lemak',
        'price': 15000,
        'stock': 8,
        'available': true,
        'icon': '🍛',
        'image': 'assets/images/nasi lemak.jpg',
      },
      {
        'name': 'Nasi Padang',
        'price': 18000,
        'stock': 8,
        'available': true,
        'icon': '🍛',
        'image': 'assets/images/Nasi Padang Legenda.jpg',
      },
    ],
    'bakso': [
      {
        'name': 'Mi Goreng',
        'price': 12000,
        'stock': 10,
        'available': true,
        'icon': '🍜',
        'image': 'assets/images/mie goreng.jpg',
      },
      {
        'name': 'Mi Ayam',
        'price': 13000,
        'stock': 8,
        'available': true,
        'icon': '🍜',
        'image': 'assets/images/mie ayam.jpg',
      },
      {
        'name': 'Mi Kuah',
        'price': 12000,
        'stock': 8,
        'available': true,
        'icon': '🍲',
        'image': 'assets/images/mie kuau.jpg',
      },
      {
        'name': 'Kwetiau Goreng',
        'price': 13000,
        'stock': 8,
        'available': true,
        'icon': '🍝',
        'image': 'assets/images/kwetiau goreng.jpg',
      },
      {
        'name': 'Bakso',
        'price': 15000,
        'stock': 10,
        'available': true,
        'icon': '🍲',
        'image': 'assets/images/bakso.jpg',
      },
      {
        'name': 'Soto Ayam',
        'price': 14000,
        'stock': 8,
        'available': true,
        'icon': '🍲',
        'image': 'assets/images/soto ayam.jpg',
      },
    ],
    'minuman': [
      {
        'name': 'Es Kosong',
        'price': 3000,
        'stock': 15,
        'available': true,
        'icon': '🧊',
        'image': 'assets/images/es kosong.jpg',
      },
      {
        'name': 'Es Milo',
        'price': 8000,
        'stock': 10,
        'available': true,
        'icon': '🥤',
        'image': 'assets/images/es milo.jpg',
      },
      {
        'name': 'Ice Cappuccino Latte',
        'price': 10000,
        'stock': 10,
        'available': true,
        'icon': '☕',
        'image': 'assets/images/ice capucino latte.jpg',
      },
      {
        'name': 'Ice Mojito',
        'price': 10000,
        'stock': 10,
        'available': true,
        'icon': '🍹',
        'image': 'assets/images/ice mujito.jpg',
      },
      {
        'name': 'Teh Hangat',
        'price': 4000,
        'stock': 15,
        'available': true,
        'icon': '🍵',
        'image': 'assets/images/teh hangat.jpg',
      },
      {
        'name': 'Teh Obeng',
        'price': 5000,
        'stock': 15,
        'available': true,
        'icon': '🧋',
        'image': 'assets/images/teh obeng.jpg',
      },
      {
        'name': 'Air Mineral',
        'price': 4000,
        'stock': 20,
        'available': true,
        'icon': '💧',
        'image': 'assets/images/air mineral.jpg',
      },
    ],
  };

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();

    final text = value?.toString().trim() ?? '';
    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? fallback;
  }

  bool _toBool(dynamic value, {bool fallback = true}) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value?.toString().trim().toLowerCase();

    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;

    return fallback;
  }

  String _normalizeName(dynamic value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  /// Memuat menu Laravel tanpa menghilangkan gambar dan ikon lokal.
  ///
  /// Menu lokal yang cocok diperbarui datanya. Menu dari server yang belum
  /// ada di daftar lokal ditambahkan ke daftar.
  Future<void> loadMenus(String canteenId, {bool forceRefresh = false}) async {
    final canteenNumber = _canteenNumbers[canteenId];

    if (canteenNumber == null || _loadingCanteens.contains(canteenId)) {
      return;
    }

    if (_loadedCanteens.contains(canteenId) && !forceRefresh) {
      return;
    }

    _loadingCanteens.add(canteenId);

    try {
      final serverMenus = await _menuApiService.getMenus(
        canteenNumber: canteenNumber,
      );

      final localMenus = _menus.putIfAbsent(canteenId, () => []);

      for (final serverMenu in serverMenus) {
        final name = serverMenu['nama_menu']?.toString().trim() ?? '';
        final serverId = _toInt(serverMenu['id']);

        if (name.isEmpty || serverId <= 0) continue;

        final index = localMenus.indexWhere(
          (menu) => _normalizeName(menu['name']) == _normalizeName(name),
        );

        final price = _toInt(serverMenu['harga']);
        final stock = _toInt(serverMenu['stok']);
        final available = _toBool(serverMenu['tersedia'], fallback: stock > 0);

        if (index >= 0) {
          // Pertahankan gambar, ikon, dan properti lokal lainnya.
          localMenus[index] = {
            ...localMenus[index],
            'name': name,
            'price': price,
            'stock': stock,
            'available': available,
            'serverId': serverId,
          };
        } else {
          // Menu baru dari Laravel tetap ditampilkan.
          localMenus.add({
            'name': name,
            'price': price,
            'stock': stock,
            'available': available,
            'icon': canteenId == 'nasi'
                ? '🍚'
                : canteenId == 'minuman'
                ? '🥤'
                : '🍜',
            'image': canteenId == 'bakso' ? 'assets/images/bakso.jpg' : '',
            'serverId': serverId,
          });
        }
      }

      _loadedCanteens.add(canteenId);

      debugPrint(
        'Menu Kantin $canteenNumber berhasil dimuat: '
        '${localMenus.map((menu) => {'name': menu['name'], 'serverId': menu['serverId'], 'price': menu['price']}).toList()}',
      );

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat menu $canteenId dari Laravel: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Jangan tandai sudah dimuat jika permintaan API gagal.
      _loadedCanteens.remove(canteenId);
    } finally {
      _loadingCanteens.remove(canteenId);
    }
  }

  /// Memaksa pemuatan ulang dari Laravel.
  Future<void> refreshMenus(String canteenId) async {
    _loadedCanteens.remove(canteenId);
    await loadMenus(canteenId, forceRefresh: true);
  }

  List<Map<String, dynamic>> getMenus(String canteenId) {
    return List<Map<String, dynamic>>.unmodifiable(
      (_menus[canteenId] ?? []).map(
        (menu) =>
            Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(menu)),
      ),
    );
  }

  /// Menambahkan menu ke Laravel sebelum memperbarui daftar lokal.
  Future<void> addMenu(String canteenId, Map<String, dynamic> menu) async {
    final canteenNumber = _canteenNumbers[canteenId];

    if (canteenNumber == null) {
      throw Exception('Nomor kantin tidak valid.');
    }

    final result = await _menuApiService.createMenu(
      canteenNumber: canteenNumber,
      menu: menu,
    );

    final serverMenu = result['data'];

    if (serverMenu is! Map || serverMenu['id'] == null) {
      throw Exception('Respons menu dari Laravel tidak valid.');
    }

    final savedMenu = Map<String, dynamic>.from(menu);
    savedMenu['serverId'] = serverMenu['id'];

    // Gunakan data resmi dari server jika tersedia.
    savedMenu['name'] =
        serverMenu['nama_menu']?.toString() ?? savedMenu['name'];
    savedMenu['price'] = _toInt(serverMenu['harga'] ?? savedMenu['price']);
    savedMenu['stock'] = _toInt(serverMenu['stok'] ?? savedMenu['stock']);
    savedMenu['available'] = _toBool(
      serverMenu['tersedia'] ?? savedMenu['available'],
    );

    final list = _menus.putIfAbsent(canteenId, () => []);
    list.add(savedMenu);

    _loadedCanteens.add(canteenId);
    notifyListeners();
  }

  /// Memperbarui menu di Laravel.
  /// Menu lokal tanpa ID server akan dibuat sebagai menu baru.
  Future<void> updateMenu(
    String canteenId,
    int index,
    Map<String, dynamic> updatedMenu,
  ) async {
    final list = _menus[canteenId];

    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    final canteenNumber = _canteenNumbers[canteenId];

    if (canteenNumber == null) {
      throw Exception('Nomor kantin tidak valid.');
    }

    final currentMenu = list[index];
    final payload = Map<String, dynamic>.from(updatedMenu);
    final serverId = currentMenu['serverId'];

    if (serverId != null && _toInt(serverId) > 0) {
      await _menuApiService.updateMenu(
        id: _toInt(serverId),
        canteenNumber: canteenNumber,
        menu: payload,
      );

      payload['serverId'] = _toInt(serverId);
    } else {
      final result = await _menuApiService.createMenu(
        canteenNumber: canteenNumber,
        menu: payload,
      );

      final serverMenu = result['data'];

      if (serverMenu is! Map || serverMenu['id'] == null) {
        throw Exception('Respons menu dari Laravel tidak valid.');
      }

      payload['serverId'] = serverMenu['id'];
    }

    list[index] = {...currentMenu, ...payload};

    notifyListeners();
  }

  /// Menghapus menu dari Laravel, lalu menghapusnya dari daftar lokal.
  Future<void> deleteMenu(String canteenId, int index) async {
    final list = _menus[canteenId];

    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    final serverId = list[index]['serverId'];

    if (serverId != null && _toInt(serverId) > 0) {
      await _menuApiService.deleteMenu(_toInt(serverId));
    }

    list.removeAt(index);
    notifyListeners();
  }

  /// Mengubah status ketersediaan menu.
  Future<void> setAvailability(
    String canteenId,
    int index,
    bool available,
  ) async {
    final list = _menus[canteenId];

    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    final updatedMenu = Map<String, dynamic>.from(list[index]);
    updatedMenu['available'] = available;

    await updateMenu(canteenId, index, updatedMenu);
  }

  /// Mengubah stok menu.
  Future<void> setStock(String canteenId, int index, int stock) async {
    final list = _menus[canteenId];

    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    final updatedMenu = Map<String, dynamic>.from(list[index]);
    updatedMenu['stock'] = stock;

    await updateMenu(canteenId, index, updatedMenu);
  }
}
