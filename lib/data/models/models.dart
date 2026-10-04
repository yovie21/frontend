class User {
  final int id;
  final String username;
  final String role;

  User({required this.id, required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      username: json['username'] ?? '',
      role: (json['role'] ?? 'kasir').toString().trim().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'username': username, 'role': role};
}

class Product {
  final int id;
  final String sku;
  final String name;
  final String? barcode;
  final int? categoryId;
  final int? uomId;
  final double price;
  final double costPrice;
  final int stock;
  final int minStock;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? uom;
  final List<dynamic>? productUoms;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    this.barcode,
    this.categoryId,
    this.uomId,
    required this.price,
    required this.costPrice,
    required this.stock,
    required this.minStock,
    this.category,
    this.uom,
    this.productUoms,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      barcode: json['barcode'],
      categoryId: json['categoryId'] != null ? (json['categoryId'] is int ? json['categoryId'] : int.tryParse(json['categoryId'].toString())) : null,
      uomId: json['uomId'] != null ? (json['uomId'] is int ? json['uomId'] : int.tryParse(json['uomId'].toString())) : null,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      minStock: (json['minStock'] as num?)?.toInt() ?? 0,
      category: json['category'],
      uom: json['uom'],
      productUoms: json['productUoms'] is List ? json['productUoms'] : [],
    );
  }
}

class Category {
  final int id;
  final String name;
  final int? parentId;

  Category({required this.id, required this.name, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      parentId: json['parentId'] != null ? (json['parentId'] is int ? json['parentId'] : int.tryParse(json['parentId'].toString())) : null,
    );
  }
}

class Uom {
  final int id;
  final String name;
  final String? symbol;

  Uom({required this.id, required this.name, this.symbol});

  factory Uom.fromJson(Map<String, dynamic> json) {
    return Uom(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      symbol: json['symbol'],
    );
  }
}

class Supplier {
  final int id;
  final String name;
  final String? contact;
  final String? phone;
  final String? email;
  final String? address;

  Supplier({required this.id, required this.name, this.contact, this.phone, this.email, this.address});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      contact: json['contact'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }
}

class SaleItem {
  final int productId;
  final String productName;
  final int qty;
  final double unitPrice;
  final double discount;
  final int conversionFactor;
  final String? uomSymbol;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    this.discount = 0.0,
    this.conversionFactor = 1,
    this.uomSymbol,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'qty': qty,
    'unitPrice': unitPrice,
    'discount': discount,
    'conversionFactor': conversionFactor,
    'uomSymbol': uomSymbol,
  };
}

class Sale {
  final int id;
  final String invoiceNo;
  final double total;
  final double discount;
  final double cashPaid;
  final double changeGiven;
  final String paymentMethod;
  final String? saleDate;
  final List<dynamic> items;

  Sale({
    required this.id,
    this.invoiceNo = '',
    required this.total,
    required this.discount,
    required this.cashPaid,
    required this.changeGiven,
    this.paymentMethod = 'tunai',
    this.saleDate,
    required this.items,
  });

  String get nota => invoiceNo.isNotEmpty ? invoiceNo : '#$id';

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      cashPaid: (json['cashPaid'] as num?)?.toDouble() ?? 0.0,
      changeGiven: (json['changeGiven'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'tunai',
      saleDate: json['saleDate']?.toString(),
      items: json['items'] is List ? json['items'] : [],
    );
  }
}

class PurchaseOrder {
  final int id;
  final String poNo;
  final String status;
  final double totalAmount;
  final double paidAmount;
  final String? orderDate;
  final Map<String, dynamic>? supplier;
  final List<dynamic> items;

  PurchaseOrder({
    required this.id,
    this.poNo = '',
    required this.status,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.orderDate,
    this.supplier,
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      poNo: json['poNo']?.toString() ?? '',
      status: json['status'] ?? 'draft',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      orderDate: json['orderDate']?.toString(),
      supplier: json['supplier'],
      items: json['items'] is List ? json['items'] : [],
    );
  }
}
