import 'package:flutter/material.dart';
import '../../data/services/services.dart';
import '../../data/models/models.dart';

class GudangProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  List<PurchaseOrder> _purchaseOrders = [];
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Product> get lowStockProducts => _lowStockProducts;
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _products.isNotEmpty) return;
    if (_products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;
    try {
      _products = await ProductService.getProducts();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStockReport() async {
    if (_lowStockProducts.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;
    try {
      _lowStockProducts = await StockService.getLowStockReport();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adjustStock(int productId, int qtyChange, {String? note}) async {
    try {
      await StockService.adjustStock(productId, qtyChange, note: note);
      await fetchProducts();
      await fetchStockReport();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPurchaseOrders() async {
    if (_purchaseOrders.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;
    try {
      final res = await Future.wait([
        StockService.getPurchaseOrders(),
        SupplierService.getSuppliers(),
        ProductService.getProducts(),
      ]);
      _purchaseOrders = res[0] as List<PurchaseOrder>;
      _suppliers = res[1] as List<Supplier>;
      _products = res[2] as List<Product>;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPurchaseOrder(Map<String, dynamic> data) async {
    try {
      await StockService.createPurchaseOrder(data);
      await fetchPurchaseOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePurchaseOrderStatus(int id, String status) async {
    try {
      await StockService.updatePurchaseOrderStatus(id, status);
      await fetchPurchaseOrders();
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> payPurchaseOrder(int id, double amount) async {
    try {
      await StockService.payPurchaseOrder(id, amount);
      await fetchPurchaseOrders();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
