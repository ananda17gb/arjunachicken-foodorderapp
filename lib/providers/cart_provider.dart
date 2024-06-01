import 'package:flutter/material.dart';
import 'package:arjunaschiken/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  List<CartModel> _cart = [];
  List<CartModel> get cart => _cart;
  int _total = 0;
  int get total => _total;

  void addRemove(String name, int menuId, bool isAdd, int price) {
    if (_cart.where((element) => menuId == element.menuId).isNotEmpty) {
      // sudah mengandung id yang diklik
      var index = _cart.indexWhere((element) => element.menuId == menuId);
      _cart[index].quantity = (isAdd)
          ? _cart[index].quantity + 1
          : (_cart[index].quantity > 0)
              ? _cart[index].quantity - 1
              : 0;
      _total = (isAdd)
          ? _total + 1
          : (_total > 0)
              ? _total - 1
              : 0;
    } else {
      // belum ada
      _cart.add(
          CartModel(name: name, menuId: menuId, quantity: 1, price: price));
      _total = _total + 1;
    }
    notifyListeners();
  }

  String getCartAsString() {
    // Convert the cart data to a string (you may need to adjust this based on your actual CartModel structure)
    return _cart
        .map((cartItem) => '${cartItem.name}: ${cartItem.quantity}')
        .join(', ');
  }

  double getTotalPrice() {
    // Calculate the total price based on your cart items (you may need to adjust this based on your actual CartModel structure)
    return _cart.fold(
        0, (total, cartItem) => total + (cartItem.quantity * cartItem.price));
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
