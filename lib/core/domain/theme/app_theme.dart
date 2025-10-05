import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryLightColor = Color.fromARGB(255, 86, 177, 251);
  static const Color textHintColor = Color(0xFF4A739C);
  static const Color deepPurpleColor = Color(0xFF6C5CE7);
  static const Color textPrimaryColor = Color.fromARGB(255, 0, 0, 0);
  static const Color lightBlue = Color.fromRGBO(232, 243, 248, 1);
  static const Color lightGrey = Color(0xffF0F2F5);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey600 = Color(0xFF757575);
  static const TextStyle headLineSmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: "SF",
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle titleMediumBold = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle titleLargeThin = TextStyle(
    fontSize: 22,

    color: textPrimaryColor,
    fontFamily: "SF",
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle titleSmallBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle bodySmallBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle bodyMini = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle bodyMediumBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: "SF",
  );
  static const TextStyle hintStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF4A739C),
    fontFamily: "SF",
  );

  static ThemeData get lightTheme => ThemeData(
    fontFamily: "SF",
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryLightColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
  );
}
