import 'dart:developer';

import 'package:flutter/services.dart';

class NativeBridge {
  static const platform = MethodChannel('com.example/native');

  static Future<String> getNativeMessage() async {
    try {
      final result = await platform.invokeMethod('getNativeMessage');
      log(result);
      return result;
    } catch (e) {
      return 'Failed to get native message: $e';
    }
  }
}
