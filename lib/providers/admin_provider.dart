import 'package:flutter/material.dart';
import '../../data/services/services.dart';
import '../../data/models/models.dart';
import '../../data/dto/dto.dart';

class AdminProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Uom> _uoms = [];
  final List<Supplier> _suppliers = [];
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<Uom> get uoms => _uoms;
  List<Supplier> get suppliers => _suppliers;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // PRODUCTS
  Future<void> fetchProducts({String? query, bool forceRefresh = false}) async {
    if (!forceRefresh && _products.isNotEmpty && query == null) return;
    if (_products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;
    try {
      _products = await ProductService.getProducts(query: query);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(ProductDto dto) async {
    try {
      await ProductService.createProduct(dto);
      await fetchProducts(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, ProductDto dto) async {
    try {
      await ProductService.updateProduct(id, dto);
      await fetchProducts(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await ProductService.deleteProduct(id);
      await fetchProducts(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // CATEGORIES
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _categories.isNotEmpty) return;
    try {
      _categories = await CategoryService.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name, {int? parentId}) async {
    try {
      await CategoryService.createCategory(name, parentId: parentId);
      await fetchCategories(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name, {int? parentId}) async {
    try {
      await CategoryService.updateCategory(id, name, parentId: parentId);
      await fetchCategories(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await CategoryService.deleteCategory(id);
      await fetchCategories(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // UOMS
  Future<void> fetchUoms({bool forceRefresh = false}) async {
    if (!forceRefresh && _uoms.isNotEmpty) return;
    try {
      _uoms = await UomService.getUoms();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createUom(String name, {String? symbol}) async {
    try {
      await UomService.createUom(name, symbol: symbol);
      await fetchUoms(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUom(int id, String name, {String? symbol}) async {
    try {
      await UomService.updateUom(id, name, symbol: symbol);
      await fetchUoms(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUom(int id) async {
    try {
      await UomService.deleteUom(id);
      await fetchUoms(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // USERS
  Future<void> fetchUsers() async {
    if (_users.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;
    try {
      _users = await UserService.getUsers();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(String username, String password, String role) async {
    try {
      await UserService.createUser(username, password, role);
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int id, {String? username, String? password, String? role}) async {
    try {
      await UserService.updateUser(id, username: username, password: password, role: role);
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await UserService.deleteUser(id);
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // SUPPLIERS
  Future<void> fetchSuppliers({bool forceRefresh = false}) async {
    if (!forceRefresh && _suppliers.isNotEmpty) return;
    try {
      _suppliers.clear();
      _suppliers.addAll(await SupplierService.getSuppliers());
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createSupplier(Map<String, dynamic> data) async {
    try {
      await SupplierService.createSupplier(data);
      await fetchSuppliers(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSupplier(int id, Map<String, dynamic> data) async {
    try {
      await SupplierService.updateSupplier(id, data);
      await fetchSuppliers(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      await SupplierService.deleteSupplier(id);
      await fetchSuppliers(forceRefresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // INITIAL LOAD
  Future<void> initAdminData() async {
    await Future.wait([
      fetchProducts(),
      fetchCategories(),
      fetchUoms(),
      fetchUsers(),
    ]);
  }

  Future<List<dynamic>> fetchStockHistory(int productId) async {
    try {
      return await StockServiceExt.getStockHistory(productId);
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> fetchSupplierReturns() async {
    try {
      return await SupplierReturnService.getSupplierReturns();
    } catch (_) {
      return [];
    }
  }

  Future<bool> createSupplierReturn({
    required int supplierId,
    required int productId,
    required int qty,
    required String reason,
  }) async {
    try {
      await SupplierReturnService.createSupplierReturn(
        supplierId: supplierId,
        productId: productId,
        qty: qty,
        reason: reason,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
