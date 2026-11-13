import 'package:dio/dio.dart';

import 'rest_api.dart';

class ApiClient extends RestApi {
  final Dio dio;
  String? token;

  ApiClient() : dio = Dio() {
    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = token;
          if (t != null) options.headers['Authorization'] = 'Bearer $t';
          handler.next(options);
        },
      ),
    );
  }
}
