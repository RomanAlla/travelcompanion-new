import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';

class ErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    } else {
      debugPrint(error.toString());
    }
    return 'Неизвестная ошибка. Попробуйте еще раз.';
  }
}
