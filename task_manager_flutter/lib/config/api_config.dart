import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5164/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5164/api';
    }

    return 'http://localhost:5164/api';
  }

  static const Duration timeoutDuration = Duration(seconds: 10);
}
