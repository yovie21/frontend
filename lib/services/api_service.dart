import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://warungku-brown.vercel.app/api';

  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static String? get token => _token;

  static Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> _headers({bool includeToken = true}) {
    final h = {'Content-Type': 'application/json'};
    if (includeToken && _token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  static Future<dynamic> _request(String method, String path, {Map<String, dynamic>? data, bool includeToken = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    http.Response r;
    final requestBody = data != null ? json.encode(data) : null;
    print('[ApiService] Request: $method $uri');
    print('[ApiService] Headers: ${_headers(includeToken: includeToken)}');
    if (requestBody != null) print('[ApiService] Body: $requestBody');
    switch (method) {
      case 'GET': r = await http.get(uri, headers: _headers(includeToken: includeToken)); break;
      case 'POST': r = await http.post(uri, headers: _headers(includeToken: includeToken), body: requestBody); break;
      case 'PATCH': r = await http.patch(uri, headers: _headers(includeToken: includeToken), body: requestBody); break;
      case 'DELETE': r = await http.delete(uri, headers: _headers(includeToken: includeToken)); break;
      default: throw Exception('Method tidak didukung');
    }
    print('[ApiService] Response ${r.statusCode}: ${r.body}');
    
    // Handle non-JSON response (HTML error pages, etc.)
    dynamic body;
    try {
      body = r.body.isEmpty ? {} : json.decode(r.body);
    } catch (e) {
      // Return raw text if not JSON
      throw Exception('Server returned non-JSON (${r.statusCode}): ${r.body.substring(0, r.body.length > 200 ? 200 : r.body.length)}');
    }
    
    if (r.statusCode >= 400) {
      throw Exception(body is Map ? (body['error'] ?? 'Error ${r.statusCode}') : 'Error ${r.statusCode}');
    }
    return body;
  }

  static Future<dynamic> get(String path) => _request('GET', path);
  static Future<dynamic> post(String path, Map<String, dynamic> data) => _request('POST', path, data: data);
  static Future<dynamic> patch(String path, Map<String, dynamic> data) => _request('PATCH', path, data: data);
  static Future<dynamic> delete(String path) => _request('DELETE', path);

  // Auth
  static Future<dynamic> login(String username, String password) =>
      _request('POST', '/auth/login', data: {'username': username, 'password': password}, includeToken: false);
  static Future<dynamic> me() => get('/auth/me');

  // Produk
  static Future<dynamic> getProduk({String? q}) => get('/products${q != null ? '?q=$q' : ''}');
  static Future<dynamic> addProduk(Map<String, dynamic> data) => post('/products', data);
  static Future<dynamic> updateProduk(int id, Map<String, dynamic> data) => patch('/products/$id', data);
  static Future<dynamic> deleteProduk(int id) => delete('/products/$id');

  // Kategori
  static Future<dynamic> getKategori() => get('/categories');
  static Future<dynamic> addKategori(String name, {int? parentId}) =>
      post('/categories', {'name': name, if (parentId != null) 'parentId': parentId});

  // UOM
  static Future<dynamic> getUom() => get('/uoms');
  static Future<dynamic> addUom(String name, {String? symbol}) =>
      post('/uoms', {'name': name, if (symbol != null) 'symbol': symbol});

  // Supplier
  static Future<dynamic> getSupplier() => get('/suppliers');
  static Future<dynamic> addSupplier(Map<String, dynamic> data) => post('/suppliers', data);

  // Stok
  static Future<dynamic> adjustStock(int productId, int qtyChange, {String? note}) =>
      post('/stock/adjust', {'productId': productId, 'qtyChange': qtyChange, if (note != null) 'note': note});

  // Penjualan
  static Future<dynamic> getPenjualan({String? from, String? to}) {
    final params = <String>[];
    if (from != null) params.add('from=$from');
    if (to != null) params.add('to=$to');
    return get('/sales${params.isEmpty ? '' : '?${params.join('&')}'}');
  }
  static Future<dynamic> addPenjualan(Map<String, dynamic> data) => post('/sales', data);
  static Future<dynamic> getPenjualanDetail(int id) => get('/sales/$id');

  // Purchase Order
  static Future<dynamic> getPO() => get('/purchase_orders');
  static Future<dynamic> addPO(Map<String, dynamic> data) => post('/purchase_orders', data);
  static Future<dynamic> updatePO(int id, String status) => patch('/purchase_orders/$id', {'status': status});

  // Laporan
  static Future<dynamic> getLaporanPenjualan({String? from, String? to}) {
    final params = <String>[];
    if (from != null) params.add('from=$from');
    if (to != null) params.add('to=$to');
    return get('/reports/sales${params.isEmpty ? '' : '?${params.join('&')}'}');
  }
  static Future<dynamic> getLaporanStok() => get('/reports/stock');
}