import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

abstract class RestApi {
  static const String _override = String.fromEnvironment('API_URL');

  String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }
}
