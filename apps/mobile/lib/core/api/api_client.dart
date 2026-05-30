import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
        onError: (error, handler) async {
          if (error.response?.statusCode != 401 || error.requestOptions.path == '/auth/refresh') {
            handler.next(error);
            return;
          }
          final refreshToken = await _sessionStore.refreshToken();
          if (refreshToken == null) {
            handler.next(error);
            return;
          }
          try {
            final refresh = await _dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken});
            final accessToken = refresh.data?['accessToken'] as String;
            final nextRefreshToken = refresh.data?['refreshToken'] as String;
            await _sessionStore.saveTokens(accessToken: accessToken, refreshToken: nextRefreshToken);
            final retry = await _dio.fetch<dynamic>(
              error.requestOptions
                ..headers['authorization'] = 'Bearer $accessToken',
            );
            handler.resolve(retry);
          } catch (_) {
            await _sessionStore.clear();
            handler.next(error);
          }
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

  Future<T> cachedGet<T>(String path, {required String cacheKey}) async {
    final box = Hive.box('swaraj_cache');
    try {
      final data = await get<T>(path);
      await box.put(cacheKey, data);
      return data;
    } catch (_) {
      final cached = box.get(cacheKey);
      if (cached != null) return cached as T;
      rethrow;
    }
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
