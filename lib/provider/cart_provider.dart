import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _cart = {}; // nama produk -> jumlah
  final Map<String, double> _prices = {}; // nama produk -> harga
  final Map<String, String> _images = {}; // nama produk -> imageUrl

  Map<String, int> get cart => _cart;
  Map<String, double> get prices => _prices;
  Map<String, String> get images => _images;

  void addItem(String name, double price, String imageUrl) {
    if (_cart.containsKey(name)) {
      _cart[name] = _cart[name]! + 1;
    } else {
      _cart[name] = 1;
      _prices[name] = price;
      _images[name] = imageUrl;
    }
    notifyListeners();
  }

  void removeItem(String name) {
    if (_cart.containsKey(name)) {
      _cart.remove(name);
      _prices.remove(name);
      _images.remove(name);
      notifyListeners();
    }
  }

  double getTotal() {
    double total = 0;
    _cart.forEach((name, qty) {
      final price = _prices[name] ?? 0.0;
      total += price * qty;
    });
    return total;
  }

  int getTotalItems() {
    return _cart.values.fold(0, (sum, qty) => sum + qty);
  }

  /// ✅ Tambahkan fungsi untuk menghapus semua isi keranjang
  void clearCart() {
    _cart.clear();
    _prices.clear();
    _images.clear();
    notifyListeners();
  }
}
