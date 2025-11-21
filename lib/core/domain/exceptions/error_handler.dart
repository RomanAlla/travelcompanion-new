import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    // Обработка ошибок Supabase
    if (error is PostgrestException) {
      return _handleSupabaseError(error);
    }

    // Обработка сетевых ошибок
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Проблема с подключением к интернету. Проверьте соединение и попробуйте снова.';
    }

    if (errorString.contains('timeout')) {
      return 'Превышено время ожидания. Попробуйте еще раз.';
    }

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Недостаточно прав для выполнения операции.';
    }

    if (errorString.contains('not found')) {
      return 'Запрашиваемый ресурс не найден.';
    }

    if (errorString.contains('already exists') || errorString.contains('duplicate')) {
      return 'Такой маршрут уже существует.';
    }

    debugPrint('Unhandled error: $error');
    return 'Произошла ошибка. Попробуйте еще раз.';
  }

  static String _handleSupabaseError(PostgrestException error) {
    final code = error.code;
    final message = error.message.toLowerCase();

    switch (code) {
      case 'PGRST116':
        return 'Запрашиваемый ресурс не найден.';
      case '23505': // unique_violation
        return 'Такой маршрут уже существует.';
      case '23503': // foreign_key_violation
        return 'Ошибка связи с данными. Проверьте корректность введенных данных.';
      case '23502': // not_null_violation
        return 'Не все обязательные поля заполнены.';
      case '42501': // insufficient_privilege
        return 'Недостаточно прав для выполнения операции.';
      default:
        if (message.contains('network') || message.contains('connection')) {
          return 'Проблема с подключением. Проверьте интернет и попробуйте снова.';
        }
        return 'Ошибка базы данных: ${error.message}';
    }
  }
}
