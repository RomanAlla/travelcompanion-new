import 'package:flutter/material.dart';

class AppTheme {
  // Цветовая палитра
  static const Color primaryColor = Color(0xFF1976D2); // Blue 700
  static const Color primaryLightColor = Color(0xFF42A5F5); // Blue 400
  static const Color primaryDarkColor = Color(0xFF0D47A1); // Blue 900
  static const Color secondaryColor = Color(0xFF26A69A); // Teal 400
  static const Color accentColor = Color(0xFFFF9800); // Orange 500

  // Нейтральные цвета
  static const Color backgroundColor = Color(0xFFFAFAFA); // Grey 50
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0); // Grey 300

  // Текстовые цвета
  static const Color textPrimaryColor = Color(0xFF212121); // Grey 900
  static const Color textSecondaryColor = Color(0xFF757575); // Grey 600
  static const Color textHintColor = Color(0xFFBDBDBD); // Grey 400

  // Цвета состояний
  static const Color successColor = Color(0xFF4CAF50); // Green 500
  static const Color errorColor = Color(0xFFF44336); // Red 500
  static const Color warningColor = Color(0xFFFF9800); // Orange 500
  static const Color infoColor = Color(0xFF2196F3); // Blue 500

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, primaryLightColor],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, accentColor],
  );

  // Типографика
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );

  // Создание основной темы
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
    scaffoldBackgroundColor: backgroundColor,
  );
}
