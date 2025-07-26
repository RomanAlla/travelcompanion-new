import 'package:travelcompanion/core/error/app_exception.dart';

class ErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Неизвестная ошибка. Попробуйте еще раз.';
  }
}
