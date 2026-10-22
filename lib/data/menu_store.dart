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

  // Memuat menu dari Laravel dan mempertahankan gambar serta ikon lokal.
  Future<void> loadMenus(String canteenId) async {
    final canteenNumber = _canteenNumbers[canteenId];

    if (canteenNumber == null ||
        _loadingCanteens.contains(canteenId) ||
        _loadedCanteens.contains(canteenId)) {
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

        if (name.isEmpty) continue;

        final index = localMenus.indexWhere(
          (menu) =>
              menu['name']?.toString().trim().toLowerCase() ==
              name.toLowerCase(),
        );

        final rawPrice = serverMenu['harga'];
        final price = rawPrice is num
            ? rawPrice.toInt()
            : (double.tryParse(rawPrice?.toString() ?? '') ?? 0).toInt();

        final rawStock = serverMenu['stok'];
        final stock = rawStock is num
            ? rawStock.toInt()
            : int.tryParse(rawStock?.toString() ?? '') ?? 0;

        final rawAvailable = serverMenu['tersedia'];
        final available =
            rawAvailable == true ||
            rawAvailable == 1 ||
            rawAvailable?.toString() == '1' ||
            rawAvailable?.toString().toLowerCase() == 'true';

        if (index >= 0) {
          localMenus[index] = {
            ...localMenus[index],
            'price': price,
            'stock': stock,
            'available': available,
            'serverId': serverMenu['id'],
          };
        } else {
          localMenus.add({
            'name': name,
            'price': price,
            'stock': stock,
            'available': available,
            'icon': '🍜',
            'image': canteenId == 'bakso' ? 'assets/images/bakso.jpg' : '',
            'serverId': serverMenu['id'],
          });
        }
      }

      _loadedCanteens.add(canteenId);
      notifyListeners();
    } catch (error) {
      debugPrint('Gagal memuat menu $canteenId dari Laravel: $error');
    } finally {
      _loadingCanteens.remove(canteenId);
    }
  }

  List<Map<String, dynamic>> getMenus(String canteenId) {
    return List<Map<String, dynamic>>.unmodifiable(
      (_menus[canteenId] ?? []).map(
        (menu) => Map<String, dynamic>.unmodifiable(menu),
      ),
    );
  }

  // Menambahkan menu ke database sebelum memperbarui tampilan.
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

    final list = _menus.putIfAbsent(canteenId, () => []);
    list.add(savedMenu);

    notifyListeners();
  }

  // Memperbarui menu di database.
  // Jika menu lokal belum mempunyai ID server, menu akan dibuat di Laravel.
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

    if (serverId != null) {
      await _menuApiService.updateMenu(
        id: int.parse(serverId.toString()),
        canteenNumber: canteenNumber,
        menu: payload,
      );

      payload['serverId'] = serverId;
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

  // Menghapus menu dari database, kemudian dari daftar lokal.
  Future<void> deleteMenu(String canteenId, int index) async {
    final list = _menus[canteenId];

    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    final serverId = list[index]['serverId'];

    if (serverId != null) {
      await _menuApiService.deleteMenu(int.parse(serverId.toString()));
    }

    list.removeAt(index);
    notifyListeners();
  }

  // Mengubah status ketersediaan menu.
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

  // Mengubah stok menu.
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
