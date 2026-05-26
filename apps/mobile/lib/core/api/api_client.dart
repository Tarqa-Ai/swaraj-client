import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/session_store.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:4000/api')));
  return ApiClient(dio, ref.read(sessionStoreProvider));
});

class ApiClient {
  ApiClient(this._dio, this._sessionStore) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStore.accessToken();
          if (token != null) options.headers['authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final SessionStore _sessionStore;

  Future<T> get<T>(String path) async {
    final response = await _dio.get<T>(path);
    return response.data as T;
  }

  Future<T> post<T>(String path, Object body) async {
    final response = await _dio.post<T>(path, data: body);
    return response.data as T;
  }

  Future<T> patch<T>(String path, Object body) async {
    final response = await _dio.patch<T>(path, data: body);
    return response.data as T;
  }
}
