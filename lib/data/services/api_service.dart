import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://192.168.1.104:7260/api',
        connectTimeout: Duration(seconds: 100),
        receiveTimeout: Duration(seconds: 300),

        /// test aşaması için bu deploy da 3 olcak
        headers: {'Content-type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // burada ister logout ister redirect yaparsın
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
