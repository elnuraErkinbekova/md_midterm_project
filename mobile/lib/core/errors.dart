import 'package:dio/dio.dart';

String errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.response == null) {
      return 'Cannot reach the server. Is it running?';
    }
    return 'Server error (${error.response?.statusCode})';
  }
  return 'Something went wrong';
}
