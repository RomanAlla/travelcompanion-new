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

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введите почту';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(value)) return 'Неверный формат';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Введите имя';
    if (value.length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }
}
