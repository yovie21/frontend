import 'package:flutter/material.dart';
import '../../data/services/services.dart';
import '../../data/models/models.dart';
import '../../data/dto/dto.dart';

class KasirProvider extends ChangeNotifier {
  List<Product> _products = [];
  final List<Map<String, dynamic>> _cart = [];
  List<Sale> _salesHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<Map<String, dynamic>> get cart => _cart;
  List<Sale> get salesHistory => _salesHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get subtotal => _cart.fold(0, (sum, item) => sum + ((item['price'] as double) * (item['qty'] as int)));

  Future<void> fetchProducts({String? query, bool forceRefresh = false}) async {
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

  int _getUsedBaseStock(int productId, {String? excludeKey}) {
    int used = 0;
    for (final item in _cart) {
      if (item['id'] == productId && item['key'] != excludeKey) {
        used += (item['qty'] as int) * (item['conversionFactor'] as int? ?? 1);
      }
    }
    return used;
  }

  void addToCart(Product p, {double? customPrice, String? uomSymbol, int conversionFactor = 1}) {
    final cartKey = '${p.id}_${uomSymbol ?? 'base'}';
    final idx = _cart.indexWhere((i) => i['key'] == cartKey);
    final selectedPrice = customPrice ?? p.price;
    final symbol = uomSymbol ?? p.uom?['symbol'] ?? 'pcs';

    final usedByOthers = _getUsedBaseStock(p.id, excludeKey: cartKey);
    final currentQtyInRow = idx >= 0 ? (_cart[idx]['qty'] as int) : 0;
    final nextBaseQty = (currentQtyInRow + 1) * conversionFactor;

    if (usedByOthers + nextBaseQty <= p.stock) {
      if (idx >= 0) {
        _cart[idx]['qty'] = currentQtyInRow + 1;
      } else {
        _cart.add({
          'key': cartKey,
          'id': p.id,
          'sku': p.sku,
          'name': p.name,
          'price': selectedPrice,
          'qty': 1,
          'uomSymbol': symbol,
          'conversionFactor': conversionFactor,
          'maxStock': p.stock,
        });
      }
    }
    notifyListeners();
  }

  void updateCartQty(String key, int delta) {
    final idx = _cart.indexWhere((i) => i['key'] == key);
    if (idx >= 0) {
      final newQty = (_cart[idx]['qty'] as int) + delta;
      final factor = (_cart[idx]['conversionFactor'] as int? ?? 1);
      final productId = _cart[idx]['id'] as int;
      final maxStock = (_cart[idx]['maxStock'] as int);

      if (newQty <= 0) {
        _cart.removeAt(idx);
      } else {
        final usedByOthers = _getUsedBaseStock(productId, excludeKey: key);
        if (usedByOthers + (newQty * factor) <= maxStock) {
          _cart[idx]['qty'] = newQty;
        }
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<Sale?> checkout(double cashPaid, {double discount = 0, String paymentMethod = 'tunai'}) async {
    final due = (subtotal - discount).clamp(0, double.infinity);
    final paid = paymentMethod == 'tunai' ? cashPaid : due;
    if (_cart.isEmpty || (paymentMethod == 'tunai' && paid < due)) return null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final items = _cart.map((i) => {
        'productId': i['id'],
        'qty': i['qty'],
        'unitPrice': i['price'],
        'conversionFactor': i['conversionFactor'] ?? 1,
        'uomSymbol': i['uomSymbol'],
        'discount': 0.0,
      }).toList();

      final dto = CheckoutDto(items: items, cashPaid: paid.toDouble(), discount: discount, paymentMethod: paymentMethod);
      final sale = await SaleService.checkout(dto);
      _cart.clear();
      await fetchProducts();
      return sale;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _salesHistory = await SaleService.getSales();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
