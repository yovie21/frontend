import '../models/models.dart';

class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class LoginResponse {
  final String token;
  final User user;
  LoginResponse({required this.token, required this.user});
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ProductDto {
  final String sku;
  final String name;
  final String? barcode;
  final int? categoryId;
  final int? uomId;
  final double price;
  final double costPrice;
  final int minStock;
  final int? initialStock;
  final List<Map<String, dynamic>>? productUoms;

  ProductDto({
    required this.sku,
    required this.name,
    this.barcode,
    this.categoryId,
    this.uomId,
    required this.price,
    required this.costPrice,
    required this.minStock,
    this.initialStock,
    this.productUoms,
  });

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': name,
        'barcode': barcode,
        'categoryId': categoryId,
        'uomId': uomId,
        'price': price,
        'costPrice': costPrice,
        'minStock': minStock,
        if (initialStock != null) 'initialStock': initialStock,
        if (productUoms != null) 'productUoms': productUoms,
      };
}

class CheckoutDto {
  final List<Map<String, dynamic>> items;
  final double discount;
  final double cashPaid;
  final String paymentMethod;

  CheckoutDto({required this.items, this.discount = 0.0, required this.cashPaid, this.paymentMethod = 'tunai'});

  Map<String, dynamic> toJson() => {
        'items': items,
        'discount': discount,
        'cashPaid': cashPaid,
        'paymentMethod': paymentMethod,
      };
}
