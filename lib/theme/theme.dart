import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF4A90E2);
const Color secondaryColor = Color(0xFFA3D8A2);
const Color errorColorLight = Color(0xFFFF6B6B);
const Color errorColorDark = Color(0xFFFF5A5A);
const Color successColorLight = Color(0xFF18BB61);
const Color successColorDark = Color(0xFF18BB61);
const Color warningColorLight = Color(0xFFFFD60A);
const Color warningColorDark = Color(0xFFCA2C);
const Color bottomColor = Color.fromARGB(255, 2, 136, 209);
const Color likeColor = Color(0xFFED4956);
const Color rateColor = Color(0xFFFFD700);
const Color linkNewContaLight = Color(0xFF4A90E2);
const Color linkEsqueceuSenhaLight = Color(0xFF000000);
const Color linkNewContaDark = Color(0xFF4A90E2);
const Color linkEsqueceuSenhaDark = Color(0xFFFFFFFF);
const Color msg = Color(0xFFFFFFFF);

ThemeData createTheme(Brightness brightness, double fontScale) {
  final bool isDark = brightness == Brightness.dark;
  
  TextTheme scaleTextTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24 * fontScale,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20 * fontScale,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16 * fontScale,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 16 * fontScale,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16 * fontScale,
      ),
    );
  }

  final baseTheme = isDark ? darkTheme : lightTheme;
  return baseTheme.copyWith(
    textTheme: scaleTextTheme(baseTheme.textTheme),
  );
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF5F5F5),
    error: errorColorLight,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  cardColor: const Color(0xFFFFFFFF),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF333333),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF333333),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'NunitoSans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF333333),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'NunitoSans',
      fontSize: 16,
      color: Color(0xFF333333),
    ),
    labelLarge: TextStyle(
      fontFamily: 'NunitoSans',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF333333),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: bottomColor,
      textStyle: const TextStyle(
        fontFamily: 'NunitoSans',
        fontSize: 16,
      ),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
    error: errorColorDark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFFE0E0E0),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFFE0E0E0),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'NunitoSans',
      fontSize: 16,
      color: Color(0xFFE0E0E0),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'NunitoSans',
      fontSize: 16,
      color: Color(0xFFE0E0E0),
    ),
    labelLarge: TextStyle(
      fontFamily: 'NunitoSans',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFFE0E0E0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: bottomColor,
      textStyle: const TextStyle(
        fontFamily: 'NunitoSans',
        fontSize: 16,
      ),
    ),
  ),
);
