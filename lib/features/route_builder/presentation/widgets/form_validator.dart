class FormValidator {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? 'Пожалуйста, заполните $fieldName'
          : 'Это поле обязательно';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) return 'Введите число';
    final number = int.tryParse(value);
    if (number == null) return 'Некорректное число';
    if (number <= 0) return 'Число должно быть положительным';
    if (number >= 1440) return 'Число не должно быть больше 1440 минут';
    return null;
  }
}
