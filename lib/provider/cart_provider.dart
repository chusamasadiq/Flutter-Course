import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';
import '../resources/db_helper.dart';

class CartProvider with ChangeNotifier {
  DBHelper db = DBHelper(); // DBHelper() is a class
  int _counter = 0;

  int get counter => _counter;

  double _totalPrice = 0.0;

  double get totalPrice => _totalPrice;

  late Future<List<Cart>> _cart;

  Future<List<Cart>> get cart => _cart; // => means to indicate

  Future<List<Cart>> getData() async {
    _cart = db.getCartList();

    return _cart;
  }

  void _setPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('cart_item', _counter);
    prefs.setDouble('total_price', _totalPrice);
    notifyListeners();
  }

  void _getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // giving initial value by ?? 0 for null safety
    _counter = prefs.getInt('cart_item') ?? 0;

    // giving initial value by ?? 0.0 for null safety
    _totalPrice = prefs.getDouble('total_price') ?? 0.0;
    notifyListeners();
  }

  void addTotalPrice(double productPrice) {
    _totalPrice = _totalPrice + productPrice;
    _setPrefItems();
    notifyListeners();
  }

  void removeTotalPrice(double productPrice) {
    _totalPrice = _totalPrice - productPrice;
    _setPrefItems();
    notifyListeners();
  }

  void resetTotalPrice() {
    _totalPrice = 0.0;
    _setPrefItems();
    notifyListeners();
  }

  void resetCounter() {
    _counter = 0;
    _setPrefItems();
    notifyListeners();
  }

  double getTotalPrice() {
    _getPrefItems();
    return _totalPrice;
  }

  void addCounter() {
    // initial value of counter was 0, will be incremented to 1, and will be stored to sharedPreferences
    _counter++;
    _setPrefItems();
    notifyListeners();
  }

  void removeCounter() {
    _counter--;
    _setPrefItems();
    notifyListeners();
  }

  int getCounter() {
    _getPrefItems();
    return _counter;
  }
}
