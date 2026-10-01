import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class HttpClient {
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
    if (includeToken && _token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  static Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? data,
    bool includeToken = true,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    http.Response r;
    final body = data != null ? json.encode(data) : null;
    const timeout = Duration(seconds: 12);

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          r = await http.get(uri, headers: _headers(includeToken: includeToken)).timeout(timeout);
          break;
        case 'POST':
          r = await http.post(uri, headers: _headers(includeToken: includeToken), body: body).timeout(timeout);
          break;
        case 'PATCH':
          r = await http.patch(uri, headers: _headers(includeToken: includeToken), body: body).timeout(timeout);
          break;
        case 'DELETE':
          r = await http.delete(uri, headers: _headers(includeToken: includeToken)).timeout(timeout);
          break;
        default:
          throw Exception('HTTP method $method tidak didukung');
      }
    } on TimeoutException {
      throw Exception('Koneksi timeout. Cek internet Anda atau coba lagi.');
    }

    dynamic responseBody;
    try {
      responseBody = r.body.isEmpty ? {} : json.decode(r.body);
    } catch (_) {
      throw Exception('Server error (${r.statusCode}): ${r.body.length > 100 ? r.body.substring(0, 100) : r.body}');
    }

    if (r.statusCode >= 400) {
      final msg = responseBody is Map ? (responseBody['error'] ?? 'Error ${r.statusCode}') : 'Error ${r.statusCode}';
      throw Exception(msg);
    }

    return responseBody;
  }

  static Future<dynamic> get(String path, {bool includeToken = true}) =>
      request('GET', path, includeToken: includeToken);

  static Future<dynamic> post(String path, Map<String, dynamic> data, {bool includeToken = true}) =>
      request('POST', path, data: data, includeToken: includeToken);

  static Future<dynamic> patch(String path, Map<String, dynamic> data, {bool includeToken = true}) =>
      request('PATCH', path, data: data, includeToken: includeToken);

  static Future<dynamic> delete(String path, {bool includeToken = true}) =>
      request('DELETE', path, includeToken: includeToken);
}
