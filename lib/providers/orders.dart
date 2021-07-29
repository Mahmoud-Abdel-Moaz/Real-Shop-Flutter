import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_shop/providers/cart.dart';
import 'package:real_shop/providers/product.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;

  getData(String? authTok, String uId, List<OrderItem> orders) {
    authToken = authTok;
    userId = uId;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://login-a2722.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            dateTime: DateTime.parse(orderData['dateTime']),
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      quantity: item['quantity'],
                      price: item['price'],
                    ))
                .toList(),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        'https://login-a2722.firebaseio.com/orders/$userId.json?auth=$authToken';

    final timeStamp = DateTime.now();
    try {
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProduct
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
            'dateTime': timeStamp.toIso8601String(),
          }));

      _orders.insert(
        0,
        OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProduct,
        ),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
