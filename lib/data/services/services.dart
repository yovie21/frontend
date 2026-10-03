import '../../core/http_client.dart';
import '../dto/dto.dart';
import '../models/models.dart';

class AuthService {
  static Future<void> setToken(String token) => HttpClient.setToken(token);
  static Future<void> clearToken() => HttpClient.clearToken();

  static Future<LoginResponse> login(String username, String password) async {
    final req = LoginRequest(username: username, password: password);
    final res = await HttpClient.post('/auth/login', req.toJson(), includeToken: false);
    return LoginResponse.fromJson(res as Map<String, dynamic>);
  }

  static Future<User> me() async {
    final res = await HttpClient.get('/auth/me');
    final map = res as Map<String, dynamic>;
    final userJson = map['user'] != null ? map['user'] as Map<String, dynamic> : map;
    return User.fromJson(userJson);
  }
}

class UserService {
  static Future<List<User>> getUsers() async {
    final res = await HttpClient.get('/users');
    return (res as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<User> createUser(String username, String password, String role) async {
    final res = await HttpClient.post('/users', {
      'username': username,
      'password': password,
      'role': role,
    });
    return User.fromJson(res as Map<String, dynamic>);
  }

  static Future<User> updateUser(int id, {String? username, String? password, String? role}) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (role != null) body['role'] = role;
    final res = await HttpClient.patch('/users/$id', body);
    return User.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> deleteUser(int id) async {
    await HttpClient.delete('/users/$id');
  }
}

class ProductService {
  static Future<List<Product>> getProducts({String? query}) async {
    final path = query != null && query.isNotEmpty ? '/products?q=$query' : '/products';
    final res = await HttpClient.get(path);
    return (res as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Product> createProduct(ProductDto dto) async {
    final res = await HttpClient.post('/products', dto.toJson());
    return Product.fromJson(res as Map<String, dynamic>);
  }

  static Future<Product> updateProduct(int id, ProductDto dto) async {
    final res = await HttpClient.patch('/products/$id', dto.toJson());
    return Product.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> deleteProduct(int id) async {
    await HttpClient.delete('/products/$id');
  }
}

class CategoryService {
  static Future<List<Category>> getCategories() async {
    final res = await HttpClient.get('/categories');
    return (res as List).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Category> createCategory(String name, {int? parentId}) async {
    final res = await HttpClient.post('/categories', {'name': name, if (parentId != null) 'parentId': parentId});
    return Category.fromJson(res as Map<String, dynamic>);
  }

  static Future<Category> updateCategory(int id, String name, {int? parentId}) async {
    final res = await HttpClient.patch('/categories/$id', {'name': name, if (parentId != null) 'parentId': parentId});
    return Category.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> deleteCategory(int id) async {
    await HttpClient.delete('/categories/$id');
  }
}

class UomService {
  static Future<List<Uom>> getUoms() async {
    final res = await HttpClient.get('/uoms');
    return (res as List).map((e) => Uom.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Uom> createUom(String name, {String? symbol}) async {
    final res = await HttpClient.post('/uoms', {'name': name, if (symbol != null) 'symbol': symbol});
    return Uom.fromJson(res as Map<String, dynamic>);
  }

  static Future<Uom> updateUom(int id, String name, {String? symbol}) async {
    final res = await HttpClient.patch('/uoms/$id', {'name': name, if (symbol != null) 'symbol': symbol});
    return Uom.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> deleteUom(int id) async {
    await HttpClient.delete('/uoms/$id');
  }
}

class SupplierService {
  static Future<List<Supplier>> getSuppliers() async {
    final res = await HttpClient.get('/suppliers');
    return (res as List).map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Supplier> createSupplier(Map<String, dynamic> data) async {
    final res = await HttpClient.post('/suppliers', data);
    return Supplier.fromJson(res as Map<String, dynamic>);
  }

  static Future<Supplier> updateSupplier(int id, Map<String, dynamic> data) async {
    final res = await HttpClient.patch('/suppliers/$id', data);
    return Supplier.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> deleteSupplier(int id) async {
    await HttpClient.delete('/suppliers/$id');
  }
}

class SaleService {
  static Future<List<Sale>> getSales({String? from, String? to}) async {
    final params = <String>[];
    if (from != null) params.add('from=$from');
    if (to != null) params.add('to=$to');
    final p = params.isEmpty ? '' : '?${params.join('&')}';
    final res = await HttpClient.get('/sales$p');
    return (res as List).map((e) => Sale.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Sale> checkout(CheckoutDto dto) async {
    final res = await HttpClient.post('/sales', dto.toJson());
    return Sale.fromJson(res as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> getSaleDetail(int id) async {
    final res = await HttpClient.get('/sales/$id');
    return res as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSalesReport({String? from, String? to}) async {
    final params = <String>[];
    if (from != null) params.add('from=${Uri.encodeQueryComponent(from)}');
    if (to != null) params.add('to=${Uri.encodeQueryComponent(to)}');
    final p = params.isEmpty ? '' : '?${params.join('&')}';
    final res = await HttpClient.get('/reports/sales$p');
    return res as Map<String, dynamic>;
  }
}

class StockService {
  static Future<void> adjustStock(int productId, int qtyChange, {String? note}) async {
    await HttpClient.post('/stock/adjust', {
      'productId': productId,
      'qtyChange': qtyChange,
      if (note != null) 'note': note,
    });
  }

  static Future<List<Product>> getLowStockReport() async {
    final res = await HttpClient.get('/reports/stock');
    return (res as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<PurchaseOrder>> getPurchaseOrders() async {
    final res = await HttpClient.get('/purchase_orders');
    return (res as List).map((e) => PurchaseOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<PurchaseOrder> createPurchaseOrder(Map<String, dynamic> data) async {
    final res = await HttpClient.post('/purchase_orders', data);
    return PurchaseOrder.fromJson(res as Map<String, dynamic>);
  }

  static Future<void> updatePurchaseOrderStatus(int id, String status) async {
    await HttpClient.patch('/purchase_orders/$id', {'status': status});
  }

  static Future<void> payPurchaseOrder(int id, double amount) async {
    await HttpClient.patch('/purchase_orders/$id', {'payAmount': amount});
  }

  static Future<List<dynamic>> getStockHistory(int productId) async {
    final res = await HttpClient.get('/stock/history?productId=$productId');
    final data = res as Map<String, dynamic>;
    return data['history'] ?? [];
  }
}

class SupplierReturnService {
  static Future<List<dynamic>> getSupplierReturns() async {
    final res = await HttpClient.get('/supplier_returns');
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createSupplierReturn({
    required int supplierId,
    required int productId,
    required int qty,
    required String reason,
  }) async {
    final res = await HttpClient.post('/supplier_returns', {
      'supplierId': supplierId,
      'productId': productId,
      'qty': qty,
      'reason': reason,
    });
    return res as Map<String, dynamic>;
  }
}

class StockServiceExt {
  static Future<List<dynamic>> getStockHistory(int productId) async {
    final res = await HttpClient.get('/stock/history?productId=$productId');
    final data = res as Map<String, dynamic>;
    return data['history'] ?? [];
  }
}

class DashboardService {
  static Future<Map<String, dynamic>> getSummary() async {
    final res = await HttpClient.get('/dashboard/summary');
    return res as Map<String, dynamic>;
  }
}

class PromoService {
  static Future<List<dynamic>> getPromos() async {
    final res = await HttpClient.get('/promos');
    return res as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createPromo({
    required String name,
    int? productId,
    double? percent,
    double? amount,
    required String startDate,
    required String endDate,
  }) async {
    final res = await HttpClient.post('/promos', {
      'name': name,
      'productId': productId,
      'percent': percent,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
    });
    return res as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updatePromo(int id, {
    String? name,
    int? productId,
    double? percent,
    double? amount,
    String? startDate,
    String? endDate,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (productId != null) data['productId'] = productId;
    if (percent != null) data['percent'] = percent;
    if (amount != null) data['amount'] = amount;
    if (startDate != null) data['startDate'] = startDate;
    if (endDate != null) data['endDate'] = endDate;
    final res = await HttpClient.patch('/promos/$id', data);
    return res as Map<String, dynamic>;
  }

  static Future<void> deletePromo(int id) async {
    await HttpClient.delete('/promos/$id');
  }
}

class AnalyticsService {
  static Future<Map<String, dynamic>> getProductAnalytics({String? from, String? to}) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await HttpClient.get('/analytics/products${query.isNotEmpty ? '?$query' : ''}');
    return res as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSalesAnalytics({String? from, String? to}) async {
    final params = <String, String>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await HttpClient.get('/analytics/sales${query.isNotEmpty ? '?$query' : ''}');
    return res as Map<String, dynamic>;
  }
}
