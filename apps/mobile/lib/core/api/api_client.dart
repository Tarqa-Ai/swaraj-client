import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/config.dart';
import '../storage/session_store.dart';

final apiClientProvider =
    Provider<ApiClient>((ref) => ApiClient(ref.read(sessionStoreProvider)));

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient(this._session);

  final SessionStore _session;

  Future<dynamic> get(String path) => _request('GET', path, null);
  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _request('POST', path, body);
  Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _request('PATCH', path, body);
  Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _request('PUT', path, body);

  Future<dynamic> _request(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    String? token = await _session.getDemoToken();
    if (token == null || token.isEmpty) {
      token = Supabase.instance.client.auth.currentSession?.accessToken;
    }
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${SwarajConfig.apiBaseUrl}$path');
    final bodyBytes = body != null ? json.encode(body) : null;

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
      case 'POST':
        response = await http.post(uri, headers: headers, body: bodyBytes);
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: bodyBytes);
      case 'PUT':
        response = await http.put(uri, headers: headers, body: bodyBytes);
      default:
        throw ArgumentError('Unknown HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    String message = 'Request failed';
    try {
      final err = json.decode(response.body);
      message = err['message'] is String
          ? err['message'] as String
          : err['message'].toString();
    } catch (_) {}
    throw ApiException(response.statusCode, message);
  }
}
