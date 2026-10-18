import 'package:flutter/foundation.dart';

class MenuStore extends ChangeNotifier {
  MenuStore._();

  static final MenuStore instance = MenuStore._();

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

  List<Map<String, dynamic>> getMenus(String canteenId) {
    return List<Map<String, dynamic>>.unmodifiable(
      (_menus[canteenId] ?? []).map(
        (menu) => Map<String, dynamic>.unmodifiable(menu),
      ),
    );
  }

  void addMenu(String canteenId, Map<String, dynamic> menu) {
    final list = _menus.putIfAbsent(canteenId, () => []);
    list.add(Map<String, dynamic>.from(menu));
    notifyListeners();
  }

  void updateMenu(
    String canteenId,
    int index,
    Map<String, dynamic> updatedMenu,
  ) {
    final list = _menus[canteenId];
    if (list == null || index < 0 || index >= list.length) return;

    list[index] = Map<String, dynamic>.from(updatedMenu);
    notifyListeners();
  }

  void deleteMenu(String canteenId, int index) {
    final list = _menus[canteenId];
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);
    notifyListeners();
  }

  void setAvailability(String canteenId, int index, bool available) {
    final list = _menus[canteenId];
    if (list == null || index < 0 || index >= list.length) return;

    list[index]['available'] = available;
    notifyListeners();
  }

  void setStock(String canteenId, int index, int stock) {
    final list = _menus[canteenId];
    if (list == null || index < 0 || index >= list.length) return;

    list[index]['stock'] = stock;
    notifyListeners();
  }
}
